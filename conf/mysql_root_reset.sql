UPDATE mysql.user SET Password=PASSWORD('passwd') WHERE User='root';
FLUSH PRIVILEGES;
DROP database test;
