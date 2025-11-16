import time
import subprocess
import sys

start = time.time()
subprocess.run(["lua", "crc32.lua", sys.argv[1]])
end = time.time()
print((end - start) * 1000000) # microseconds
