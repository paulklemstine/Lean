# Future Directions: Erdős–Straus Conjecture

## 1. Residue Covering Completeness via Modulus 840

**Conjecture.** There exists a finite set of at most 20 explicit parametric identities for 4/n = 1/x + 1/y + 1/z whose associated congruence classes form a complete covering system modulo 840 — that is, every residue class mod 840 is covered by at least one parametric family.

**Test.** For each residue r mod 840 with r ≡ 1 (mod 12) (the only residue class our current four families miss), search for an identity of the form x = ⌈αn⌉ for various rational α, derive closed-form (y,z) via the algebraic equation z = nxy/(4xy − n(x+y)), and check whether the resulting formula yields integer solutions for all n ≡ r (mod 840). Verify computationally for all r ∈ {1, 13, 25, 37, 49, 61, ...} mod 840 and check coverage.

**Impact.** A complete covering mod 840 would reduce the conjecture to finitely many prime residue classes, each requiring only bounded computational verification. Combined with the prime reduction theorem, this would essentially reduce the conjecture to a finite computation plus a density argument.

---

## 2. Quadratic Witness Bound for Exceptional Primes

**Conjecture.** For every prime p ≡ 1 (mod 12), there exists an Erdős–Straus decomposition 4/p = 1/x + 1/y + 1/z with x ≤ p, y ≤ p², z ≤ p². Moreover, one can always choose x = ⌈p/4⌉ or x = ⌈p/4⌉ + 1.

**Test.** For all primes p ≡ 1 (mod 12) up to 10⁶, compute the minimal ordered solution (x ≤ y ≤ z) and record max(z)/p². If the ratio stays bounded, the conjecture is supported. If x = ⌈p/4⌉ works for density > 99% of such primes, this would yield a near-proof strategy: prove x = ⌈p/4⌉ works generically, then handle exceptions by a secondary family.

**Impact.** An explicit polynomial bound on witness size would transform the search problem from unbounded to polynomial-time certifiable, connecting the conjecture to computational complexity theory and making large-scale formal verification feasible.

---

## 3. Two-Parameter Surface Parametrization for n ≡ 1 (mod 12)

**Conjecture.** For primes p ≡ 1 (mod 12), the affine surface S_p: 4xyz = p(xy + xz + yz) admits a two-parameter rational parametrization (a,b) ↦ (x(a,b), y(a,b), z(a,b)) with x,y,z polynomial in a,b of degree ≤ 3, such that for each p the parametrization covers all solutions with x ≤ p.

**Test.** Fix several primes p ≡ 1 (mod 12) (e.g., 13, 37, 61, 73, 97). Enumerate all solutions on S_p with coordinates ≤ 10⁴. Attempt to fit a rational parametrization using interpolation over the solution set. Verify the parametrization yields integer points for a random sample of (a,b) values.

**Impact.** Such a parametrization would provide a geometric proof of the conjecture for this residue class, connecting the number-theoretic problem to the algebraic geometry of rational surfaces. It would also yield an O(1) algorithm for finding decompositions.

---

## 4. Modular Arithmetic Obstruction Classification

**Conjecture.** The equation 4xyz ≡ 0 (mod p) with xy + xz + yz ≡ 0 (mod p) has solutions modulo every prime p. More precisely, for each prime p, the number of solutions (x,y,z) mod p to 4xyz ≡ p·(xy + xz + yz) (mod p²) is at least p² − 2p.

**Test.** For each prime p up to 1000, count solutions mod p² by exhaustive enumeration. If the count is always ≥ p² − 2p, this rules out local obstructions and suggests the Hasse principle applies to the Erdős–Straus surface. Formalize the mod-p solution count as a theorem.

**Impact.** Proving absence of local obstructions would be a major structural result. Combined with a suitable form of the circle method or sieve, it could potentially lead to an unconditional proof of the conjecture for all sufficiently large n.

---

## 5. Certified Verification to 10^14 via Parallel Search

**Conjecture.** The Erdős–Straus conjecture holds for all n ≤ 10^14, verifiable by a combination of: (a) the four algebraic families covering 11/12 of integers, (b) extended parametric families covering additional residue classes mod 840, and (c) a parallel smart search for the remaining ~0.5% of integers requiring computational verification.

**Test.** Implement the smart search algorithm in a compiled language (Rust/C++), parallelized across residue classes. For each exceptional n ≡ 1 (mod 12) up to 10^14, run the O(n) smart search (x ranges over [⌈n/4⌉, n], z is computed). Generate certified witnesses and verify them against the Diophantine equation. Import the witness certificates into the formal verification framework.

**Impact.** This would extend the verified bound by several orders of magnitude beyond current published results. The certified witness format would allow the formal proof system to verify each decomposition in O(1) time, creating a scalable bridge between computational number theory and formal mathematics.
