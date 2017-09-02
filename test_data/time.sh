i=3 
while(($i >= 0)); do
	echo -ne  "\033[41;33mSome changes, It will update itself $i...\033[0m\r"
	sleep 1
	let i=i-1
done
echo -e ""
