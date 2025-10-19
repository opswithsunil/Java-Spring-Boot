create table if not exists items (
    id bigserial primary key,
    name varchar(255) not null,
    description varchar(1024),
    created_at timestamptz not null,
    updated_at timestamptz not null
);

