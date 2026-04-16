# Autoresearch Ideas Backlog

## Active
- [ ] **C/GMP SIQS**: Would be 10-100x faster than Python SIQS. Could push max_bits to 200+.
- [ ] **Adaptive ECM schedule**: Larger B1 for larger numbers. Skip B1=2K for 140+ bit.
- [ ] **Cyclotomic channel factoring**: Only works for smooth-order numbers. Research whether hybrid approach (cyclotomic + order finding) can improve on ECM.

## Tried and Kept
- [x] **ECM-first cascade** ★★★★★: gmp-ecm subprocess BEFORE rho. 94→167 bits in 3s.
- [x] **GMP rho** ★★★★: C-level rho via ctypes+libgmp. 85% at 80-bit.
- [x] **Dual-walk rho** ★★★: x²+x+c walk function.
- [x] **CRT Multi-Lens Fermat**: 506-2049x search reduction.
- [x] **SQUFOF**: Works but slower than ECM for >80-bit.

## Tried and Rejected
- [x] ~~Williams p+1~~: WORSE for balanced semiprimes
- [x] ~~ECM for balanced semiprimes~~: subprocess gmp-ecm is better
- [x] ~~Interleaved rho~~: Buggy, dual-walk is better
- [x] ~~Conditional (x-y)~~: Branch overhead worse
- [x] ~~Residue sieve per-candidate~~: CRT precompute is better
- [x] ~~Multi-walk rho~~: Overhead exceeds benefit in Python
- [x] ~~B1=25M ECM~~: WORSE (too slow per curve)
- [x] ~~Cyclotomic channel factoring~~: Only works for smooth-order numbers, NOT general semiprimes
- [x] ~~Smooth order channels~~: Same as p-1/p+1, fails for balanced semiprimes
- [x] ~~QDF quadruple division~~: Random search, probability too low
- [x] ~~SIQS in Python~~: Works but 10-20s for 120+ bit. Needs C implementation.