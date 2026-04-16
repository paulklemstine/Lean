# Autoresearch Ideas Backlog

## Tried and Kept
- [x] **Dual-walk rho** ★★★: x²+x+c walk function, 57% improvement. Alternating with x²+c.
- [x] **Adaptive CRT**: 9 lenses for 56+ bit, 7 for smaller
- [x] **Rho micro-opts**: batch=1024, max_r=8N^{1/4}, local vars

## High Priority
- [ ] **rho with gmpy2**: C-level modular arithmetic could give 10-100x at 80+ bits
- [ ] **Proper SQUFOF**: Careful CF implementation for 40-70 digit numbers
- [ ] **Quadratic Sieve**: Real QS with sieving — should dominate at 80+ digits

## Tried and Rejected
- [x] ~~Williams p+1 in cascade~~: WORSE for balanced semiprimes (17ms overhead)
- [x] ~~ECM for balanced semiprimes~~: Marginal (1% improvement at 80-bit, overhead)
- [x] ~~Interleaved rho~~: Buggy implementation, dual-walk is better
- [x] ~~Conditional (x-y) instead of (x-y)%nm~~: Branch overhead worse than mod
- [x] ~~Residue sieve per-candidate checking~~: CRT precompute is better

## Medium Priority
- [ ] Batch rho with numpy: Vectorize inner loop
- [ ] Parallel rho with multiprocessing
- [ ] Adaptive rho: switch c range based on bit size
- [ ] CRT lens with 11+ lenses for 80-bit numbers

## Low Priority
- [ ] FFT diffraction with larger M
- [ ] CRT lens + IOF hybrid
- [ ] ECM + p-1 combined (check both in same pass)