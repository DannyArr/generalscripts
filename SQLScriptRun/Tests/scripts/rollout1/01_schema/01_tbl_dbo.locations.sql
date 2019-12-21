use Sandbox;

if object_id('dbo.locations') is null
begin
	create table dbo.locations (
		[id] int identity(1,1),
		[locationName] nvarchar(50) not null,
		[status] bit null
		constraint [pk_location_id] primary key clustered (id),
	);

	print('Table dbo.locations created');

end
else print('Table dbo.locations already exists. Doing nothing.');

waitfor delay '00:00:03'
