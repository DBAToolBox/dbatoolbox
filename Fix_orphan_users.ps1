$serverList=@('ServerName\InstanceName')

foreach($Instance in $serverList)

    {

        $database_List=Invoke-Sqlcmd -ServerInstance $Instance -Database master -Query "select @@servername as ServerInstance,name from sys.databases where database_id>4" -OutputAs DataRows
        foreach($Database in $database_List)
            {

               $OrphanUser_List= Invoke-Sqlcmd -ServerInstance $Database.ServerInstance -Database $Database.name -Query "Select DB_NAME() AS DatabaseName,S.Name as Login_Name,D.Name as DB_user_Name FROM sys.server_principals S INNER JOIN sys.database_principals D ON S.NAME COLLATE Latin1_General_CI_AS_KS_WS=D.NAME COLLATE Latin1_General_CI_AS_KS_WS 
                WHERE S.TYPE='S' COLLATE Latin1_General_CI_AS_KS_WS AND D.TYPE='S' COLLATE Latin1_General_CI_AS_KS_WS AND S.SID <> D.SID" -OutputAs DataRows
                foreach($orphanUser in $OrphanUser_List)
                    {

                        $orphan_DatabaseName=$orphanUser.DatabaseName
                        $orphan_Login_Name=$orphanUser.Login_Name
                        $orphan_User_Name=$orphanUser.DB_user_Name
                        $Fix_User="ALTER USER $orphan_User_Name WITH LOGIN = $orphan_Login_Name"
                        Invoke-Sqlcmd -ServerInstance $Database.ServerInstance -Database $orphan_DatabaseName -Query $Fix_User

                    }

            }


    }
