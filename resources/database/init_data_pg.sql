-- PostgreSQL Initial Data for Ragent

INSERT INTO t_user (id, username, password, role, avatar, create_time, update_time, deleted)
VALUES (2001523723396308993, 'admin', 'admin', 'admin', 'https://static.deepseek.com/user-avatar/G_6cuD8GbD53VwGRwisvCsZ6', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0),
       (2001523723396308994, '张三', '123456', 'user', 'https://static.deepseek.com/user-avatar/G_6cuD8GbD53VwGRwisvCsZ6', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0);
