# Future Directions: Sums of Three Cubes — Local-Global Infrastructure

## Hypothesis 1: CRT Decomposition of Local Solvability

**Conjecture:** For coprime positive integers $m$ and $n$, the local representability predicate decomposes via the Chinese Remainder Theorem:
$$\text{LocRep}(mn, a) \iff \text{LocRep}(m, a \bmod m) \wedge \text{LocRep}(n, a \bmod n).$$

**Test:** Verify computationally for all coprime pairs $(m, n)$ with $m, n \leq 50$ by exhaustive enumeration of residues. Formalize the proof using the `ZMod.ringEquiv` isomorphism $\mathbb{Z}/mn\mathbb{Z} \cong \mathbb{Z}/m\mathbb{Z} \times \mathbb{Z}/n\mathbb{Z}$ from Mathlib's `ZMod.chineseRemainder`.

**Impact:** If true, this reduces all local obstruction analysis to prime-power moduli — a massive simplification. It would let us build a compositional local solvability engine: check at each prime power independently, then combine. This transforms the mod-9 result from a standalone fact into the first entry in a systematic table.

---

## Hypothesis 2: Prime-Power Lifting (Hensel's Lemma for Three Cubes)

**Conjecture:** For every odd prime $p \neq 3$, if $\text{LocRep}(p, a)$ holds, then $\text{LocRep}(p^k, a')$ holds for all $k \geq 1$ and all lifts $a'$ of $a$. That is, nonsingular local solutions at primes $p \neq 3$ lift to all $p$-adic levels.

**Test:** Verify computationally for $p \in \{5, 7, 11, 13, 17, 19, 23\}$ and $k \leq 4$. For the formal proof, use Hensel's lemma: the Jacobian of $f(x,y,z) = x^3 + y^3 + z^3 - n$ is $(3x^2, 3y^2, 3z^2)$, which is nonzero mod $p$ whenever at least one coordinate is nonzero mod $p$ and $p \neq 3$.

**Impact:** Combined with Hypothesis 1, this would give: for $p \neq 3$, a single check at $p$ suffices for all $p$-adic levels. The interesting case is $p = 3$ (equivalently, powers of 9), where lifting is more delicate. Formalizing this would capture the essential $p$-adic obstruction theory without full $\mathbb{Q}_p$ infrastructure.

---

## Hypothesis 3: Density of Representable Integers Among Admissible Classes

**Conjecture:** Among mod-9-admissible integers $n \leq N$ (i.e., $n \not\equiv 4, 5 \pmod{9}$), the fraction that are representable as sums of three cubes tends to 1 as $N \to \infty$.

**Test:** Computationally, determine the representability status of all admissible $n \leq 10^3$ using brute-force search with increasing bounds. Track the ratio of represented vs. unknown. Use the formal density framework (the `count_admissible_mod9_block` theorem) to state the conjecture precisely:
$$\lim_{N \to \infty} \frac{|\{n \leq N : n \text{ admissible and representable}\}|}{|\{n \leq N : n \text{ admissible}\}|} = 1.$$

**Impact:** This is the central open problem in the field. Even partial progress — e.g., showing the lower density is positive, or that the set of admissible non-representable integers has density 0 — would be major. The formalized counting framework enables precise formal statements of such conjectures and could support future formalization of analytic number theory bounds.

---

## Hypothesis 4: Local-Global Gap for Three Cubes

**Conjecture:** There exists an integer $n$ that is everywhere locally soluble (i.e., $\text{LocRep}(m, n)$ holds for all $m \geq 1$) but is not globally representable as a sum of three cubes.

**Test:** Identify candidate $n$ values that pass all modular tests up to $m \leq 1000$ but resist computational search for representations. The integers $n \in \{33, 42, 114, 165, \ldots\}$ were historically such candidates until large solutions were found. Formalize the local condition `HasLocalPointEverywhere n` and attempt to verify it for specific $n$. If $n$ passes all local tests but no representation is known (or can be shown not to exist), this provides evidence for the gap.

**Impact:** The existence or non-existence of such a gap determines whether the Hasse principle holds for the cubic surface $x^3 + y^3 + z^3 = n$. If a gap exists, it would be one of the simplest known failures of the Hasse principle for affine varieties. If no gap exists — if the Hasse principle holds — it would be a remarkable positive result in arithmetic geometry. Either way, the formal infrastructure for stating and investigating this question is a significant contribution.

---

## Hypothesis 5: Additive Combinatorics of Cube Sumsets in Finite Rings

**Conjecture:** For every odd integer $m$ coprime to 3, the triple sumset of cubes covers all of $\mathbb{Z}/m\mathbb{Z}$:
$$C_m + C_m + C_m = \mathbb{Z}/m\mathbb{Z}, \quad \text{where } C_m = \{x^3 : x \in \mathbb{Z}/m\mathbb{Z}\}.$$

**Test:** Verify for all odd $m$ coprime to 3 with $m \leq 200$. If failures exist, characterize them. The cube image $C_m$ has size $|C_m| = (m-1)/\gcd(3, m-1) + 1$ by Lagrange's theorem on subgroups of $(\mathbb{Z}/m\mathbb{Z})^\times$. For $m$ coprime to 3, every element is a cube in $(\mathbb{Z}/m\mathbb{Z})^\times$, so $|C_m| = m$ and the conjecture is trivially true. The interesting cases are $m$ divisible by primes $\equiv 1 \pmod{3}$ (where the cube map is 3-to-1) — check whether the triple sumset still covers despite the smaller cube set.

**Impact:** Understanding when the local equation has full coverage connects to the Waring problem over finite rings. Proving that triple cube sumsets cover $\mathbb{Z}/m\mathbb{Z}$ for large classes of $m$ would show that the mod-9 obstruction is essentially the *only* obstruction from finite-ring arithmetic. This would strongly support the density conjecture and provide evidence for the Hasse principle holding.
