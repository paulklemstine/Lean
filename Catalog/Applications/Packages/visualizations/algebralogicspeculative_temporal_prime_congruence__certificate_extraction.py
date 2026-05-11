#!/usr/bin/env python3
"""
Algorithms for Temporal Prime Congruence Spectrum Analysis

Implements the core algorithms:
1. Temporal congruence enumeration
2. Prime (meet-irreducible) congruence detection
3. Separation decision procedure
4. Orbit certificate extraction
5. Spectrum construction
"""

from typing import List, Tuple, Set, Dict, Optional
from dataclasses import dataclass