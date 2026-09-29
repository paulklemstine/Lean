# Computational evidence — MASTER-TABLE (paper 119)

This is **numerical exploration only**: a short floating-point enumeration run
before and alongside the formal work. Every exact value quoted in the master
table is proved separately in Lean (`Catalog/Algebra/MasterTable*.lean`). The
decimals below come from brute-force enumeration and are not themselves
formally checked.

## 1. Small cases, n = 3 … 12 (bits)

Columns: `H(T)` cyclic = entropy of `ordType n a` over `a ∈ range n`;
`H(#roots)` cyclic = entropy of `rootCount n (ordType n a)`; `pinEnt n`;
`H(T)` dihedral = entropy of `fixCount` on `D_n`; type distribution on `D_n`;
`H(T|rot)` = conditional entropy given the rotation character; `I` = `H(T) - H(T|rot)`;
`I/H` = abelian share.

| n | H(T) C_n | H(#roots) C_n | pinEnt n | H(T) D_n | D_n types | H(T\|rot) | I(rot;T) | I/H |
|---|---|---|---|---|---|---|---|---|
| 3 | 0.9183 | 0.9183 | 0.9183 | 1.4591 | {3:1, 0:2, 1:3} | 0.4591 | 1.0000 | 0.6853 |
| 4 | 1.5000 | 0.8113 | 0.8113 | 1.2988 | {4:1, 0:5, 2:2} | 0.9056 | 0.3932 | 0.3027 |
| 5 | 0.7219 | 0.7219 | 0.7219 | 1.3610 | {5:1, 0:4, 1:5} | 0.3610 | 1.0000 | 0.7348 |
| 6 | 1.9183 | 0.6500 | 0.6500 | 1.1887 | {6:1, 0:8, 2:3} | 0.8250 | 0.3637 | 0.3060 |
| 7 | 0.5917 | 0.5917 | 0.5917 | 1.2958 | {7:1, 0:6, 1:7} | 0.2958 | 1.0000 | 0.7717 |
| 8 | 1.7500 | 0.5436 | 0.5436 | 1.1216 | {8:1, 0:11, 2:4} | 0.7718 | 0.3499 | 0.3119 |
| 9 | 1.2244 | 0.5033 | 0.5033 | 1.2516 | {9:1, 0:8, 1:9} | 0.2516 | 1.0000 | 0.7990 |
| 10 | 1.7219 | 0.4690 | 0.4690 | 1.0763 | {10:1, 0:14, 2:5} | 0.7345 | 0.3418 | 0.3176 |
| 11 | 0.4395 | 0.4395 | 0.4395 | 1.2197 | {11:1, 0:10, 1:11} | 0.2197 | 1.0000 | 0.8198 |
| 12 | 2.4183 | 0.4138 | 0.4138 | 1.0434 | {12:1, 0:17, 2:6} | 0.7069 | 0.3365 | 0.3225 |

Patterns seen in the numbers, all of which were then proved in Lean for every `n`:

* `H(#roots) = pinEnt n` in every row (`rootCountEntropy_eq_pinEnt`);
* `H(#roots) = H(T)` exactly at the primes 3, 5, 7, 11 and strictly smaller otherwise
  (`rootCount_lossless_iff_prime`);
* the `D_n` type distributions are `{0:n-1, 1:n, n:1}` for odd n and
  `{0:3n/2-1, 2:n/2, n:1}` for even n (`typeCounts_odd`, `typeCounts_even`);
* for odd n, `H(T|rot) = pinEnt(n)/2` and `I = 1` (`condEnt_rotSign_odd`,
  `mutInfo_rotSign_odd`); for even n, `I < 1` (`mutInfo_rotSign_even_lt_one`);
* along odd n the share `I/H` rises towards 1 (`abelian_saturation_odd`).

## 2. OEIS

The type-count sequences are standard: the odd `D_n` counts `(n-1, n, 1)` and the
even counts `(3n/2 - 1, n/2, 1)` are linear in n, and the cyclic type counts are
`φ(d)` for `d | n` (A000010). No new sequence was needed, so no OEIS lookup was done.

## 3. Counterexample hunt

* Checked `rootCount lossless ⇔ n prime` for n = 2…12: no counterexample
  (proved in general in Lean).
* Checked `I(rot;T) = 1 ⇔ n odd` for n = 3…12: no counterexample (proved in general).
* A boundary case found during the formalization: at `n = 2` the odd/even laws break
  down, because the identity (2 fixed points) and the axis reflections (2 fixed points)
  have the same type. That is why the Lean statements assume `n ≥ 3` (odd n) or
  `n ≥ 4` (even n).

## 4. Open numerical observation (not proved)

Along even n the dial value `I(rot;T)` appears to decrease towards
`h(1/4) - 1/2 ≈ 0.3113`, where `h` is the binary entropy (see the table and
`FUTURE_DIRECTIONS.md`).
