"""Does PARI actually FAIL at the n=800 GIFP instance? r112 says yes
('>4 min without success'); r112's OWN committed log hardN2.log says it
SUCCEEDED in 310.72 s. Reproduce both claims on the identical instance."""
import time
from cypari2 import Pari
p = Pari()
# EXACT instance from r112/verify_gifp/hardN2.sage.py, reproduced & verified
N2 = None
import subprocess
