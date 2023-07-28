# import os
# #pdf_files = [f for f in os.listdir('.') if os.path.isfile(f) and f.endswith('.pdf')]
#
# for f in os.listdir('.'):
#     if os.path.isfile(f) and f.endswith('.pdf'):
#         print(f)


#!/bin/python3

import math
import os
import random
import re
import sys



#!/bin/python3

import math
import os
import random
import re
import sys



N = int(input().strip())

if N % 2 != 0:
    print ("Weird")
else:
    if N >= 2 and N <= 5:
        print ("Not Weird")
    elif N >= 6 and N <= 20:
        print ("Weird")
    elif N > 20:
        print ("Not Weird")
