import psutit

def check_cpu_usage(threshold):
	usage = psutil.cpu_percent(interval=1)
	if usage > threshold:
		print(f"Warning: CPU usage is {usage}%!")
	else:
		print (f"CPU usage is normal: {usage}%")

# Set threshold to 89%
check_cpu_usage(80)

