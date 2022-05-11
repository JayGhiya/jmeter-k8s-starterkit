slave_array=(10.42.0.219 10.42.0.220); index=2 && while [ ${index} -gt 0 ]; do for slave in ${slave_array[@]}; do if echo 'test open port' 2>/dev/null > /dev/tcp/${slave}/1099; then echo ${slave}' ready' && slave_array=(${slave_array[@]/${slave}/}); index=$((index-1)); else echo ${slave}' not ready'; fi; done; echo 'Waiting for slave readiness'; sleep 2; done
echo "Installing needed plugins for master"
cd /opt/jmeter/apache-jmeter/bin
sh PluginsManagerCMD.sh install-for-jmx k8s-load-test.jmx
jmeter -Ghost=google.com -Gport=443 -Gprotocol=https -Gthreads=10 -Gduration=60 -Grampup=6  --logfile /report/k8s-load-test.jmx_2022-05-12_010256.jtl --nongui --testfile k8s-load-test.jmx -Dserver.rmi.ssl.disable=true --remoteexit --remotestart 10.42.0.219,10.42.0.220 >> jmeter-master.out 2>> jmeter-master.err &
trap 'kill -10 1' EXIT INT TERM
java -jar /opt/jmeter/apache-jmeter/lib/jolokia-java-agent.jar start JMeter >> jmeter-master.out 2>> jmeter-master.err
wait
