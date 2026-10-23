# Computational evidence: branch value vs conic value

Exploratory Python computation (not machine-checked; the Lean-verified statements are listed
at the end). Population: the **uniform factor battery**, i.e. all pairs \((p,q)\in\mathbb F_q^2\), each once.
Branch value = \(I(L;s,d) - I(L;s,d^2)\), conic value = \(I(L;s,d^2) - I(L;N)\), in bits.

| q | \(H(s,d)-H(s,d^2)\) | split fraction \((q-1)/q\) | L = s (swap-invariant): hint / branch / conic | L = d: hint / branch / conic |
|---|---|---|---|---|
| 5  | 0.8000 | 0.8000 | 1.6212 / 0 / 1.6212 | 1.6212 / 0.8000 / 0.8212 |
| 7  | 0.8571 | 0.8571 | 2.0238 / 0 / 2.0238 | 2.0238 / 0.8571 / 1.1666 |
| 11 | 0.9091 | 0.9091 | 2.5986 / 0 / 2.5986 | 2.5986 / 0.9091 / 1.6895 |
| 13 | 0.9231 | 0.9231 | 2.8185 / 0 / 2.8185 | 2.8185 / 0.9231 / 1.8954 |
| 31 | 0.9677 | 0.9677 | 4.0041 / 0 / 4.0041 | 4.0041 / 0.9677 / 3.0364 |

Observations:
1. **Counterexample hunt**: the swap-invariant label \(L = s\) has a large hint value (4.0 bits at \(q=31\)),
   whereas the ramification locus \(d=0\) is only a \(1/q\) fraction of the population. So the conjecture
   "swap-invariant hint value = ramified hint value" is false, and badly so.
2. Branch value of \(L=s\) is \(0\) in every case (proved in Lean in general:
   `branchValue_eq_zero_of_swapInvariant`).
3. For \(L = d\) the branch value equals \((q-1)/q\) = the split fraction, so the bound
   `branchValue_le_split_fraction` is attained on the uniform battery in these cases (observed numerically only).
4. No OEIS lookup applies (the quantities are real-valued entropies, not an integer sequence).

Lean-verified small cases (exact, in `Catalog/Logic/BranchRamification.lean`):
* battery \((1,2),(3,4)\) mod 5, labels \(0,1\): swap-invariant, empty ramification locus, hint value exactly 1 bit;
* battery \((1,2),(2,1)\) mod 5: branch value exactly 1, conic value 0;
* battery \((1,1),(4,4)\) mod 5 (all on \(d=0\)): hint value 1, branch value 0, conic value 1.
