use Sandbox;

if object_id('dbo.$(TableName)') is null
begin
	create table dbo.$(TableName) (
		[id] int identity(1,1),
		[Col1] nvarchar(50) not null
	);

	print('Table dbo.$(TableName) created');

end
else print('Table dbo.$(TableName) already exists. Doing nothing.');