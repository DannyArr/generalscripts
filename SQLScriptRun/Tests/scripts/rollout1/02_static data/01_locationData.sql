use Sandbox;

print 'GO GO GO'

if object_id('tempdb..#tmp_locations') is not null drop table #tmp_locations;
create table #tmp_locations (
	[locationName] nvarchar(100),
	[status] bit
);

insert into #tmp_locations
values
	 ('York',1)
	,('Cape Town',1)
	,('Jo''burg',1)
	,('Pretoria',0)
	,('Dublin',1)
	,('London',1)
	,('$(SpecialValue)',0)
;

merge [dbo].[locations] as tgt
using #tmp_locations as src
on (src.locationName = tgt.locationName)
when matched
	then update set tgt.[status] = src.[status]
when not matched by target
	then insert(locationName,[status]) values(src.locationName,src.[status])
when not matched by source
	then delete;
