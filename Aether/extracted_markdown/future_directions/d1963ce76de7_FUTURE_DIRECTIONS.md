# Future Directions: Reverse-and-Add Dynamics

## Conjecture 1: Carry-Chain Length Divergence for 196

**Precise Statement:** Let $c_k$ denote the maximum length of a consecutive carry chain (a maximal sequence of positions with nonzero carry) when computing $T^k(196) + \mathrm{rev}(T^k(196))$. Then $\limsup_{k \to \infty} c_k = \infty$.

**Test:** Compute the carry profiles for the first $10^6$ iterates of 196 (feasible with big-integer arithmetic). Track the maximum consecutive carry chain length at each step. If $c_k$ remains bounded by some constant $C$ for all tested $k$, the conjecture is refuted.

**Impact:** If true, this would explain why palindrome formation is difficult for 196: long carry chains create cascading disruptions that prevent the digit string from settling into a symmetric pattern. This would be a key ingredient in a dynamical obstruction proof.

## Conjecture 2: Modular Residue Obstruction for 196 Orbit

**Precise Statement:** For all $k \geq 1$, if $T^k(196)$ has an even number of digits, then $T^k(196) \not\equiv 0 \pmod{11}$.

Combined with our formally verified theorem that even-length palindromes must be divisible by 11, this would prove that no even-length palindrome ever appears in the 196 orbit.

**Test:** Compute $T^k(196) \bmod 11$ and the digit length for the first $10^7$ iterates. Check whether any even-length iterate has residue 0 mod 11. A single counterexample (an even-length iterate with $T^k(196) \equiv 0 \pmod{11}$) would refute this conjecture. Note: refutation would NOT mean a palindrome exists — only that this particular sieve fails.

**Impact:** If true, this eliminates half of all potential palindrome formations (the even-length ones) from the 196 orbit, reducing the problem to odd-length palindromes only. Combined with analogous odd-length obstructions, this could yield a complete non-termination proof.

## Conjecture 3: Symmetry Defect Growth Rate

**Precise Statement:** Let $\delta_k = \mathrm{symmetryDefect}(\mathrm{digits}_{10}(T^k(196)))$. Then there exists a constant $\alpha > 0$ such that
$$\liminf_{k \to \infty} \frac{\delta_k}{\log(T^k(196))} \geq \alpha.$$

That is, the symmetry defect grows at least logarithmically with the value.

**Test:** Compute $\delta_k$ and $\log_{10}(T^k(196))$ for $k$ up to $10^5$. Plot $\delta_k / \log_{10}(T^k(196))$ and check if it stays bounded away from zero. If $\delta_k / \log_{10}(T^k(196)) \to 0$, the conjecture is refuted.

**Impact:** If true, this provides a quantitative lower bound on how far each iterate is from being a palindrome, growing with the iterate's size. This would be a Lyapunov-type certificate for non-termination: not only does the orbit never reach defect zero, but it stays increasingly far from zero in a normalized sense.

## Conjecture 4: Finite Signature Automaton for Non-Palindromicity

**Precise Statement:** There exists a finite set $S$ of digit signatures (each recording digit length modulo some period $p$, residues mod 9 and mod 11, and a carry parity bit) such that:
1. The signature of 196 lies in $S$.
2. $S$ is closed under the reverse-and-add transition.
3. No signature in $S$ is compatible with being a palindrome.

**Test:** For various choices of the period $p$ (e.g., $p = 2, 3, 4, 6$) and carry parity definitions, enumerate all reachable signatures from 196's initial signature under the induced transition relation. Check whether any reachable signature could correspond to a palindrome. If every explored closure contains a palindrome-compatible signature, refute this conjecture for that parameter choice.

**Impact:** If true for some $p$, this would constitute a finite-state non-termination certificate — a proof that 196 is Lychrel, reducible to checking a finite automaton. This would be the strongest possible form of the result, equivalent to proving the 196 conjecture via a decidable computation.

## Conjecture 5: Universal Palindrome Avoidance for Carry-Dense Seeds

**Precise Statement:** Define a number $n$ as *carry-dense* if the carry density (fraction of digit positions producing a carry in $n + \mathrm{rev}(n)$) exceeds 0.6. Then every carry-dense number $n > 100$ with $n \bmod 10 \neq 0$ satisfies: $T(n)$ is also carry-dense.

**Test:** Enumerate all carry-dense numbers up to $10^8$. For each, compute $T(n)$ and check its carry density. A single carry-dense $n$ whose image is not carry-dense refutes the conjecture.

**Impact:** If true, this identifies a "trapping region" in the carry-density space. Combined with the observation that carry-dense numbers have high symmetry defect (due to frequent digit overflow), this would show that certain orbits are permanently trapped in a palindrome-avoiding region. This is the dynamical-systems approach to Lychrel behavior: not proving that one specific orbit avoids palindromes, but that an entire class of orbits does.
