#!/bin/bash
sudo apt update -y
sudo apt install apache2 -y
sudo systemctl start apache2
sudo systemctl start apache2
cat <<EOF > /var/www/html/index.html
<html>
<h2>Practicing Terraform</h2><br>
<h3>Owner: ${f_name} ${l_name}</h3><br>
<h3><i>Some of my skills are:<i></h3><br>
<ul>
%{ for skill in my_skills ~}
    <li>${skill}</li><br>
%{ endfor ~}
</ul>
</html>
EOF


