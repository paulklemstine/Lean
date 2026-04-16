# Autoresearch Ideas Backlog

## High Priority
- [ ] **Interleaved rho**: Run 5 different c values in lockstep, check batch GCDs for each. If c=3 finds the factor but we're on c=1, we waste time. Interleaving means we'd find it ~5x sooner in expectation.
- [ ] **Proper SQUFOF**: Careful CF-based implementation with correct parity handling. Should be 10-100x faster than rho at 40-70 digits.
- [ ] **Adaptive CRT lens count**: At 80-bit, use 9 lenses (2049x reduction) since Fermat range is large. At 48-bit, use 7 lenses.

## Medium Priority  
- [ ] **rho with gmpy2**: If available, gmpy2 provides C-level modular arithmetic, potentially 10-100x speedup for 80+ bit numbers
- [ ] **Williams p+1 in C**: Lucas chain computation is O(1) but Python loop kills it. A subprocess call to compiled C would be instant.
- [ ] **Quadratic Sieve proper**: Build real QS with sieving and linear algebra. Should dominate rho at 80+ digits.

## Low Priority / Long Shots
- [ ] **Parallel rho with multiprocessing**: Python's multiprocessing could parallelize across c values
- [ ] **FFT diffraction with larger M**: Current M = min(10000, N^{1/4}). For 80-bit, try M = N^{1/2} (better detection range, but slower)
- [ ] **CRT lens + IOF hybrid**: Apply CRT lens optimization to the IOF bleg sequence
- [ ] **Batch rho with numpy**: Vectorize the inner loop using numpy arrays instead of Python loops