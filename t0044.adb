-- t0044.adb - Sun Jan 19 16:41:21 2014
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Ada.Text_IO;

with Posix, System;
use Posix;

procedure T0044 is
   use Ada.Text_IO, System;

   Shmid :     int_t := -1;
   Page_Size : long_t := 0;
   Info :      s_shmid_ds;
   Addr :      System.Address;
   Error :     errno_t;
begin

   Put_Line("Test 0044 - Shmget/Shmctl");

   -- Get the page sizew
   Sysconf(SC_PAGESIZE,Page_Size,Error);
   pragma Assert(Error = 0);
   pragma Assert(Page_Size >= 1024);

   -- Create Shared Memory Region of 1 Page
   Shmget(IPC_PRIVATE,size_t(Page_Size),IPC_CREAT or IPC_EXCL or 8#700#,Shmid,Error);
   if Error = EEXIST then
      -- Remove the old set
      Shmctl(Shmid,IPC_RMID,Error);
      pragma Assert(Error = 0);

      -- Create a new set of semaphores, as before
      Shmget(IPC_PRIVATE,2,IPC_CREAT or IPC_EXCL or 8#700#,Shmid,Error);
   end if;

   pragma Assert(Error = 0);
   pragma Assert(Shmid >= 0);

   -- Query status of shmid
   Shmctl_Get(Shmid,IPC_STAT,Info,Error);
   pragma Assert(Error = 0);
   pragma Assert((Info.shm_perm.mode and 8#777#) = 8#700#);

   Info.shm_perm.mode := Info.shm_perm.mode or 8#040#;
   Shmctl_Set(Shmid,IPC_SET,Info,Error);
   pragma Assert(Error = 0);

   -- Query status of shmid (check result of IPC_SET)
   Shmctl_Get(Shmid,IPC_STAT,Info,Error);
   pragma Assert(Error = 0);
   pragma Assert((Info.shm_perm.mode and 8#777#) = 8#740#);

   -- Attach to shared memory
   Addr := System.Null_Address;
   Shmat(Shmid,Addr,0,Error);
   pragma Assert(Error = 0);
   pragma Assert(Addr /= System.Null_Address);

   declare
      Test_Shm :  String(1..9);
      for Test_Shm'Address use Addr;
   begin
      Test_Shm := "It works!";
   end;

   -- Detach
   
   Shmdt(Addr,Error);
   pragma Assert(Error = 0);

   -- Test -- Reattach shared memory

   Addr := System.Null_Address;
   Shmat(Shmid,Addr,0,Error);
   pragma Assert(Error = 0);
   pragma Assert(Addr /= System.Null_Address);

   declare
      Test_Shm :  String(1..9);
      for Test_Shm'Address use Addr;
   begin
      pragma Assert(Test_Shm = "It works!");
      null;
   end;

   -- Remove shared memory
   Shmctl(Shmid,IPC_RMID,Error);
   pragma Assert(Error = 0);

   Put_Line("Test 0044 Passed.");

end T0044;
