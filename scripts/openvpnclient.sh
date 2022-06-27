
#!/bin/bash

#make sure user is logged in as root
if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root; run \"sudo -i\" this will log you into root." 
   exit 1
fi
echo "Lets go"

#varibles up front
proxy=/etc/environment
aptd=/etc/apt/apt.conf.d
echo "Variables set"

#update and install
apt update -y
apt install openvpn

#get user certs and password file
echo "Is your username in your client config? y/n"
read -r conf
if [[ $config == n ]]
then
	echo "what is the absolute path to your openvpn cert?"
	read -r cert
	echo "What is your username?"
	read -r user
	echo "What is your password?"
	read -r pass
	touch /etc/openvpn/creds
	cred=/etc/openvpn/creds
	echo "$user" > $cred
	echo "$pass" >> $cred
elif [[ $config == y ]]
then
	echo "what is the absolute path to your openvpn cert?"
	read -r cert
	echo "do you have a password file set up?"
	read -r yn
	if [[ $yn == y ]]
	then
   		echo "what is the absolute path to your password file?"
   		read -r pass
	else
   		echo "what is your password?"
   		read -r word
   		touch word.txt
   		echo "$word" >> word.txt
   		pass=word.txt
	fi
echo "Pass and cert set"   

#adding proxy configs
echo "export http_proxy=\"http://10.8.0.1:9997/\"" >> $proxy
echo "export https_proxy=\"http://10.8.0.1:9997/\"" >> $proxy
echo "no_proxy=\"localhost,127.0.0.1\"" >> $proxy
touch $aptd/10proxy
echo "Acquire::http::Proxy\"http://10.8.0.1:9997/\";" >> $aptd/10proxy 
echo "Defaults       env_keep+=\"http_proxy https_proxy no_proxy\"" >> /etc/sudoers.tmp
echo "Proxy set"

#Make openvpn script
touch openvpn.sh
sh=openvpn.sh
echo "#!/bin/bash" >> $sh
echo " " >> $sh
echo "openvpn --config $cert --askpass $pass --daemon" >> $sh
sleep 1
chmod +x $sh
cp $sh /bin/
wait
echo "vpn file made"

#Move services 
#serv=/root/ClosedVpn/services/openvpn.service
#cp "$serv" /etc/systemd/system/
#sleep 1
#systemctl enable openvpn.service
#wait
#echo "service moved and enabled"

#Make ifmetric if using a cell hat
echo "Are you using a cell hat? y/n"
read -r cell
if [ "$cell" == y ]
then
	cellsh=/etc/NetworkManager/dispatcher.d/set_metrics.sh
	touch $cellsh	
	echo "#!/bin/bash/" >> $cellsh
	echo " " >> $cellsh
	echo "ifmetric wwan0 1" >> $cellsh
	echo "ifmetric usb0 2" >> $cellsh
	echo "ifmetric tun0 3" >> $cellsh
	echo "ifmetric wlan1 10" >> $cellsh
	echo "ifmetric wlan0 20" >> $cellsh
	echo "ifmetric eth0 700" >> $cellsh
	chmod +x $cellsh
fi

echo "done for now reboot and test"
