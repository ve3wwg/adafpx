-- t0043.adb - Sat Jan 18 20:34:05 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- $Id$
--
-- Protected under the GNU GENERAL PUBLIC LICENSE v2, June 1991

with Ada.Text_IO;

with Posix;
use Posix;

procedure T0043 is
   use Ada.Text_IO;    

   Semid :     int_t := -1;
   Info :      s_semid_ds;
   Sems :      ushort_array := ( 99, 99 );
   Sem_Val :   int_t := -1;
   Error :     errno_t;
begin

   Put_Line("Test 0043 - Semget/Semctl");

   -- Create semaphore set of 2
   Semget(IPC_PRIVATE,2,IPC_CREAT or IPC_EXCL or 8#700#,Semid,Error);
   if Error = EEXIST then
      -- Remove the old set
      Semctl(Semid,IPC_RMID,Error);
      pragma Assert(Error = 0);
      -- Create a new set of semaphores, as before
      Semget(IPC_PRIVATE,2,IPC_CREAT or IPC_EXCL or 8#700#,Semid,Error);
   end if;

   pragma Assert(Error = 0);
   pragma Assert(Semid >= 0);

   -- IPC_STAT
   Semctl(Semid,IPC_STAT,Info,Error);
   pragma Assert(Error = 0);
   pragma Assert((Info.sem_perm.mode and 8#777#) = 8#700#);
   pragma Assert(Info.sem_nsems = 2);
   
   -- Get the values of our pair of semaphores (should be zero)
   Semctl_Get(Semid,IPC_GETALL,Sems,Error);
   pragma Assert(Error = 0);
   pragma Assert(Sems = (0, 0));

   -- Set the semaphores to arbitrary values
   Sems := ( 1, 2 );
   Semctl_Set(Semid,IPC_SETALL,Sems,Error);   
   pragma Assert(Error = 0);

   -- Get the values of our pair of semaphores (should be zero)
   Sems := ( 0, 0 );
   Semctl_Get(Semid,IPC_GETALL,Sems,Error);
   pragma Assert(Error = 0);
   pragma Assert(Sems = (1, 2));

   -- Change the permissions slightly
   Info.sem_perm.mode := Info.sem_perm.mode or 8#040#;
   Semctl_Set(Semid,IPC_SET,Info,Error);
   pragma Assert(Error = 0);

   -- Verify that the permission bit got set
   Info.sem_perm.mode := 0;
   Semctl(Semid,IPC_STAT,Info,Error);
   pragma Assert(Error = 0);
   pragma Assert((Info.sem_perm.mode and 8#777#) = 8#740#);
   pragma Assert(Info.sem_nsems = 2);

   -- Test that there are no waiters on the first semaphore
   Semctl_Get(Semid,IPC_GETVAL,0,Sem_Val,Error);
   pragma Assert(Error = 0);
   pragma Assert(Sem_Val = 1);

   Semctl_Get(Semid,IPC_GETVAL,1,Sem_Val,Error);
   pragma Assert(Error = 0);
   pragma Assert(Sem_Val = 2);

   -- Test IPC_SETVAL
   Semctl_Set(Semid,IPC_SETVAL,1,0,Error);
   pragma Assert(Error = 0);

   -- Verify IPC_SETVAL
   Sems := ( 0, 0 );
   Semctl_Get(Semid,IPC_GETALL,Sems,Error);
   pragma Assert(Error = 0);
   pragma Assert(Sems = (1, 0));

   -- Wait on semaphore 0, notify 1
   declare
      Ops : constant s_sembuf_array := (
         ( sem_num => 0, sem_op => -1, sem_flg => 0 ),
         ( sem_num => 1, sem_op => +1, sem_flg => 0 )
      );
   begin
      Semop(Semid,Ops,Error);
      pragma Assert(Error = 0);
   end;

   -- Check the semaphore values
   Semctl_Get(Semid,IPC_GETALL,Sems,Error);
   pragma Assert(Error = 0);
   pragma Assert(Sems = (0, 1));

   -- Now perform the reverse ops
   declare
      Ops : constant s_sembuf_array := (
         ( sem_num => 0, sem_op => +1, sem_flg => 0 ),
         ( sem_num => 1, sem_op => -1, sem_flg => 0 )
      );
   begin
      Semop(Semid,Ops,Error);
      pragma Assert(Error = 0);
   end;

   -- Check the semaphore values
   Semctl_Get(Semid,IPC_GETALL,Sems,Error);
   pragma Assert(Error = 0);
   pragma Assert(Sems = (1, 0));

   -- Remove the semaphore set
   Semctl(Semid,IPC_RMID,Error);
   pragma Assert(Error = 0);

   Put_Line("Test 0043 Passed.");

end T0043;
