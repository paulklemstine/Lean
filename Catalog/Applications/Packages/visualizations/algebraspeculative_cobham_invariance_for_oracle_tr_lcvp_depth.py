from typing import List, Tuple, Set, Callable, Optional, Dict
import itertools
from dataclasses import dataclass
from typing import List, Callable, Tuple, Dict
import random
import math
from algorithms import lcvp_depth, make_drop_prefix, make_append_suffix
from typing import List, Tuple, Dict, Any
import itertools
import itertools
import math
import base64
import io

def lcvp_depth(x, y):
    depth = 0
    for a, b in zip(x, y):
        if a != b:
            break
        depth += 1
    return depth