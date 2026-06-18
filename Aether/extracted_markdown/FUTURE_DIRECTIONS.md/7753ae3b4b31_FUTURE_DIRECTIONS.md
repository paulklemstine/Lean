# Future Directions: Beal Conjecture Obstruction Theory

## Direction 1: Residue-Class Covering for Primitive Beal Triples

**Conjecture:** There exists a finite set of moduli $M = \{m_1, \ldots, m_k\}$ such that every pairwise coprime triple $(A, B, C)$ with $A^x + B^y = C^z$ and $x, y, z > 2$ violates at least one power-residue constraint modulo some $m_i \in M$.

**Test:** Compute power-residue tables for prime moduli up to 200 and composite moduli up to 100. For each exponent triple $(x, y, z)$ with $x, y, z \in \{3, 4, 5, 6, 7\}$, enumerate all coprime residue patterns $(A \bmod m, B \bmod m, C \bmod m)$ that are compatible with $A^x + B^y \equiv C^z \pmod{m}$. Search for a finite covering set $M$ such that the intersection of surviving patterns across all $m \in M$ is empty.

**Refutation:** Exhibit a specific coprime residue pattern that survives all tested moduli simultaneously. If for every finite $M$ there exists a surviving pattern, then modular obstructions alone cannot resolve Beal.

**Impact:** If a covering exists, it would reduce Beal to a finite verification problem for each exponent triple—a certified computational proof. This would be the first instance of a covering argument resolving an open Diophantine conjecture.

---

## Direction 2: Quantitative ABC Threshold Sufficient for Beal

**Conjecture:** There exists an explicit $\varepsilon_0 > 0$ (specifically, $\varepsilon_0 = 1$ suffices) such that the integer ABC hypothesis $c \leq \mathrm{rad}(abc)^{1+\varepsilon_0}$ formally implies the absence of all pairwise coprime Beal solutions with $x, y, z > 2 + 2/\varepsilon_0$.

**Test:** Our formal theorem `abc_int_implies_no_primitive_beal_K2` already establishes this for $K = 2$ (corresponding to $\varepsilon_0 = 1$) with the exponent threshold at $x, y, z > 6$. The next step is to:
1. Formalize the analogous result for $K = 3$ ($\varepsilon_0 = 2$) and verify whether the threshold drops to $x, y, z > 4$.
2. Investigate whether the "7th power trick" (raising the ABC bound to the 7th power) can be replaced by a sharper argument using $n$-th powers for optimal $n$.
3. Derive the exact minimal $K$ needed to cover all exponents $> 2$.

**Refutation:** Show that for any $K$, there exist exponent triples $(x, y, z)$ with $x, y, z > 2$ for which the bound $C^z \leq (ABC)^K$ is consistent with $A^x + B^y = C^z$ for infinitely many pairwise coprime triples. This would demonstrate that a uniform integer ABC bound cannot resolve Beal without additional structure.

**Impact:** Establishing the exact ABC strength needed for Beal would quantify the gap between the current state of the ABC conjecture and a full resolution of Beal. It would also provide a roadmap for conditional results as effective ABC bounds improve.

---

## Direction 3: Descent by Common-Prime Extraction is Height-Complete

**Conjecture:** Every non-primitive solution to $A^x + B^y = C^z$ (where a prime divides all three bases) admits a canonical "common-factor extraction" reduction to a solution with strictly smaller height $H(A, B, C) = \max(A, B, C)$, and this reduction terminates at either a primitive (pairwise coprime) solution or a trivial identity.

**Test:** Define the reduction relation formally:
- Given $A^x + B^y = C^z$ with a common prime $p \mid A, B, C$, write $A = p^a A'$, $B = p^b B'$, $C = p^c C'$ where $p \nmid A'B'C'$.
- Derive conditions under which the equation $A'^{x} + B'^{y} = C'^{z}$ (after extracting appropriate powers of $p$) holds.
- Prove well-foundedness of the induced reduction chain using the height $\max(A, B, C)$.

**Refutation:** Exhibit a family of solutions where common-factor extraction increases the height of one base while decreasing another, creating a non-decreasing branch. Alternatively, show that extraction of different common primes can lead to different terminal primitive solutions, demonstrating non-canonicity.

**Impact:** A formally verified terminating reduction would provide the infrastructure for "assume pairwise coprime WLOG" arguments in all future Beal-related work, completing the formal reduction theory.

---

## Direction 4: Valuation Rigidity at Small Primes

**Conjecture:** For any pairwise coprime solution to $A^x + B^y = C^z$ with $x, y, z > 2$, the 2-adic valuation $v_2(C^z)$ satisfies one of at most 4 patterns depending on the parities of $A, B$ and the exponents. Specifically:
- Exactly one of $A, B$ is even (since they are coprime), and $C$ is odd.
- If $A$ is even and $B, C$ are odd, then $v_2(A^x) = v_2(C^z - B^y)$, which constrains $v_2(A)$ to be exactly $v_2(C^z - B^y) / x$.
- This forces $x \mid v_2(C^z - B^y)$, providing a divisibility constraint.

**Test:** For each exponent triple $(x, y, z)$ with $3 \leq x, y, z \leq 10$:
1. Enumerate 2-adic valuation patterns $(v_2(A), v_2(B), v_2(C))$ compatible with the equation.
2. Cross-reference with 3-adic patterns.
3. Count the number of surviving combined patterns.

**Refutation:** Produce infinitely many compatible 2-adic/3-adic valuation patterns for a single exponent triple, demonstrating that valuation constraints alone cannot resolve the conjecture even locally.

**Impact:** If the number of compatible valuation patterns is small and finite for each exponent triple, this could seed a comprehensive local-to-global obstruction argument. Combined with modular covering (Direction 1), this could yield new special-case impossibility results.

---

## Direction 5: The (3,3,3) Boundary Controls All Primitive Cases

**Conjecture:** Any pairwise coprime solution to $A^x + B^y = C^z$ with $x, y, z > 2$ admits a formal "exponent reduction" to a structurally related obstruction in the cubic equation $A'^3 + B'^3 = C'^{z'}$. Specifically, if $(A, B, C, x, y, z)$ is a primitive Beal solution with $x, y \geq 3$, then there exist $A', B', C'$ derived from $A, B, C$ by algebraic operations (factorization in $\mathbb{Z}[\omega]$, descent, or resultant constructions) such that $A'^3 + B'^3 = C'^{z'}$ for some $z' > 2$.

**Test:** 
1. For odd exponents $x = 2k+1$, factor $A^{2k+1} + B^{2k+1}$ over $\mathbb{Z}$ as $(A+B)(A^{2k} - A^{2k-1}B + \cdots + B^{2k})$ and study when this yields a cube-sum structure.
2. For the boundary case $x = y = z = 3$: Fermat's Last Theorem (proved by Wiles) shows no coprime solution exists. Verify formally that the FLT implication can be stated cleanly in our framework.
3. For $x = y = 3, z > 3$: study the equation $A^3 + B^3 = C^z$ and whether known results (e.g., Darmon-Granville) give formal impossibility.

**Refutation:** Construct a family of primitive solutions to $A^x + B^y = C^z$ with $x, y > 3$ that have no algebraic relationship to any cubic equation. This would demonstrate that the cubic boundary is not universal and that Beal requires genuinely higher-degree methods.

**Impact:** If the cubic boundary controls all cases, then resolving Beal reduces to understanding the generalized Fermat equation $A^3 + B^3 = C^z$, which is a much more tractable target with existing arithmetic geometry tools (Frey curves, modularity, Galois representations).
