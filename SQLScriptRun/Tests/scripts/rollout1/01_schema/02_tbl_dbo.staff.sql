use Sandbox;

if object_id('dbo.staff') is null
begin
	create table dbo.staff (
		[id] int identity(1,1),
		[locationId] int not null,
		[staffName] nvarchar(50) not null,
		[status] bit null,
		constraint [pk_staff_id] primary key clustered (id),
		constraint [fk_location_id] foreign key (locationId) references [dbo].[locations](id)
	);

	print('Table dbo.staff created');

end
else print('Table dbo.staff already exists. Doing nothing.');
