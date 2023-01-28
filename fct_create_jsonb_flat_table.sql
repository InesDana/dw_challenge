-- source: https://stackoverflow.com/questions/35178102/flatten-aggregated-key-value-pairs-from-a-jsonb-field/35179515#
-- but craete table not view
create or replace function create_jsonb_flat_table
    (table_name text, regular_columns text, json_column text)
    returns text language plpgsql as $$
declare
    cols text;
begin
    execute format ($ex$
        select string_agg(format('%2$s->>%%1$L "%%1$s"', key), ', ')
        from (
            select distinct key
            from %1$s, json_each(%2$s)
            order by 1
            ) s;
        $ex$, table_name, json_column)
    into cols;
    execute format($ex$
        drop table if exists %1$s_table; --exchange view for table
        create table %1$s_table as --exchange view for table
        select %2$s, %3$s from %1$s
        $ex$, table_name, regular_columns, cols);
    return cols;
end $$;