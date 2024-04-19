Use DataDiningRoom
Go

-- 1.

Drop trigger if exists TR_MenuItem_Update
Go

Create Trigger TR_MenuItem_Update
On MenuItem
for Update
As
	IF Update(Price)
	Begin
		if exists (Select * FROM Inserted As i
					JOIN deleted As d
					On i.MenuItemID=d.MenuItemID
					Where i.Price > d.Price * 1.14)
		Begin
			ROLLBACK TRANSACTIOn
			RAISERROR('You cannot increAse the price by more than 14 percent', 16, 1)
		End
	End
Return

-- 2.
Drop trigger if exists TR_Training_Insert_Update
Go

Create Trigger TR_Training_Insert_Update
On Training
for Insert, Update
As
	IF @@ROWCOUNT > 0 AND Update(Cost)
	Begin
		if exists (Select * FROM Inserted As i Where Cost > 200)
		Begin
			Update Training SET Cost=200 Where TrainingID=@@IDENTITY
		End
	End
Return
Go

-- 3. 
Drop trigger if exists TR_ReservatiOn_Log
Go

Create Trigger TR_ReservatiOn_Log
On ReservatiOn
for Insert
As
	DECLARE @CustomerID int
	Select @CustomerID=CustomerID FROM Inserted
	IF @@ROWCOUNT > 0
	Begin
		IF (Select COUNT(*) FROM ReservatiOn Where CustomerID=@CustomerID) > 3
		Begin
			IF NOT EXISTS (Select * FROM FrequentCustomer Where CustomerID=@CustomerID)
			Begin
				Insert INTO FrequentCustomer(CustomerID, FirstName, LAstName)
				Select i.CustomerID, c.Firstname, C.LAstname FROM Inserted As i 
				JOIN Customer As c On i.CustomerID=c.CustomerID
			End
		End
	End
Return
Go


-- 4.

Drop trigger if exists TR_Staff_Insert_Update
Go

Create Trigger TR_Staff_Insert_Update
On Staff
for Insert, Update
As
	DECLARE @StaffCount TINYINT
	IF @@ROWCOUNT > 0 OR Update(StaffTypeID)
	Begin
		Select @StaffCount=COUNT(*) FROM Staff Where StaffTypeID=(Select StaffTypeID FROM Inserted)
		IF @StaffCount > 3
		Begin
			ROLLBACK TRANSACTIOn
			RAISERROR('This Staff Type cannot have more than 3 Staff.', 16, 1)
		End
	End
Return
Go


-- 5. 

Drop trigger if exists TR_ReservatiOn_Insert_Update
Go

Create Trigger TR_ReservatiOn_Insert_Update
On ReservatiOn
for Insert, Update
As
	IF @@ROWCOUNT > 0 OR Update(StaffID)
	Begin
		IF NOT EXISTS (Select s.StaffTypeID FROM Inserted As i JOIN Staff As s On s.StaffID=i.StaffID Where s.StaffTypeID=2)
		Begin
			ROLLBACK TRANSACTIOn
			RAISERROR('Cant Assign staff if StaffType is not Host', 16, 1)
		End
	End
Return
Go

-- 6
Drop trigger if exists TR_ReservatiOn_Insert
Go 

Create Trigger TR_ReservatiOn_Insert
On ReservatiOn
for Insert
As
	if exists (Select * FROM ReservatiOn As r JOIN Inserted As I On i.ReservatiOnID=r.ReservatiOnID Where r.NoShow='N')
	Begin
		ROLLBACK TRANSACTIOn
		RAISERROR('Customer have a No Show record. Cant add reservatiOn', 16, 1)
	End

Return
Go

-- 7
Drop trigger if exists TR_ReservatiOn_Update
Go

Create Trigger TR_ReservatiOn_Update
On ReservatiOn
for Update
As
	IF Update(CustomerID)
	Begin
		ROLLBACK TRANSACTIOn
		RAISERROR('A ReservatiOn cant be transferred to a different customer', 16, 1)
	End
Return
Go