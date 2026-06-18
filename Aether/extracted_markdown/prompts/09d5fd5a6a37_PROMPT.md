

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Defin

## YOUR ASSIGNMENT: Thermodynamic Diophantine Cryptanalysis: Berggren Transfer Operators for Certified Security of Triple-Based One-Way Maps

Create a new bridge file formalizing a thermodynamic-cryptographic interface for triple-based one-way maps, with exact Lean statements, explicit finite-depth counting bounds, and spectral-radius-to-security inequalities. The central goal is to turn transfer-operator control on the Berggren tree into certified post_quantum_security bounds for collision and preimage events of Diophantine hash/one-way constructions.

Work over concrete finite-depth truncations so every main theorem is fully computable in Lean, while organizing definitions so they transparently approximate the infinite thermodynamic formalism. The file should be a complete narrative: definitions → combinatorial counting lemmas → transfer-operator identities → pressure inequalities → cryptographic corollaries.

### Required new definitions and structures

Introduce at least the following, with doc comments explicitly saying `Bridge: connects thermodynamic formalism to cryptographic security` and using keywords such as `entropy`, `post_quantum_security`, `certified_robustness`, `lattice_crypto`, `quantum_walk` where appropriate.

```lean
/-- Bridge: connects thermodynamic formalism to cryptographic security on the Berggren tree. -/
structure BerggrenCryptoObservable where
  weight : ℤ × ℤ × ℤ → ℝ
  nonneg : ∀ t, 0 ≤ weight t
  depthLipschitz : ℝ
  depthLipschitz_nonneg : 0 ≤ depthLipschitz
  depth_control :
    ∀ a b c a' b' c' : ℤ,
      |weight (a,b,c) - weight (a',b',c')|
        ≤ depthLipschitz * (|a - a'| + |b - b'| + |c - c'|)

/-- Finite-depth partition sum for cryptographic observables on Berggren descendants. -/
def CryptoPartitionSum
    (F : BerggrenCryptoObservable)
    (seed : ℤ × ℤ × ℤ)
    (n : ℕ) : ℝ :=
  ∑ t in berggrenDescendants seed n, Real.exp (F.weight t)

/-- Collision count at depth `n` for a finite-output hash on Berggren descendants. -/
def CollisionCount
    (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ)
    (n : ℕ) : ℕ :=
  ((berggrenDescendants seed n).offDiag.filter
    (fun p => H p.1 = H p.2)).card

/-- Normalized collision pressure, logarithmic in the partition sum scale. -/
def CollisionPressure
    (F : BerggrenCryptoObservable)
    (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ)
    (n : ℕ) : ℝ :=
  Real.log (CollisionCount H seed n + 1) - 2 * Real.log (CryptoPartitionSum F seed n)

/-- Preimage count of a target hash value at depth `n`. -/
def PreimageCount
    (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ)
    (n : ℕ)
    (y : Fin m) : ℕ :=
  ((berggrenDescendants seed n).filter fun t => H t = y).card

/-- Certified finite-depth security profile extracted from transfer bounds. -/
structure BerggrenSecurityProfile where
  collisionExponent : ℝ
  preimageExponent : ℝ
  spectralUpper : ℝ
  entropyGap : ℝ
  collisionExponent_nonneg : 0 ≤ collisionExponent
  preimageExponent_nonneg : 0 ≤ preimageExponent
  entropyGap_nonneg : 0 ≤ entropyGap

/-- A finite-depth transfer iterate driven by a crypto observable. -/
def CryptoTransferIterate
    (F : BerggrenCryptoObservable)
    (g : ℤ × ℤ × ℤ → ℝ)
    (seed : ℤ × ℤ × ℤ)
    (n : ℕ) : ℝ :=
  ∑ t in berggrenDescendants seed n, Real.exp (F.weight t) * g t

/-- Depth-normalized collision probability among independently F-weighted descendants. -/
def WeightedCollisionProbability
    (F : BerggrenCryptoObservable)
    (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ)
    (n : ℕ) : ℝ :=
  (∑ p in (berggrenDescendants seed n).offDiag,
      if H p.1 = H p.2 then
        Real.exp (F.weight p.1 + F.weight p.2)
      else 0)
  / (CryptoPartitionSum F seed n)^2

/-- Maximum point mass of the weighted output distribution. -/
def WeightedPreimageProbability
    (F : BerggrenCryptoObservable)
    (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ)
    (n : ℕ)
    (y : Fin m) : ℝ :=
  (∑ t in (berggrenDescendants seed n).filter fun t => H t = y,
      Real.exp (F.weight t))
  / CryptoPartitionSum F seed n

/-- Spectral-radius surrogate usable in finite-depth certified bounds. -/
def FiniteDepthSpectralRate
    (F : BerggrenCryptoObservable)
    (seed : ℤ × ℤ × ℤ)
    (n : ℕ) : ℝ :=
  (Real.log (CryptoPartitionSum F seed (n+1)) - Real.log (CryptoPartitionSum F seed n))

/-- Security profile extracted from explicit finite-depth inequalities. -/
def securityProfileOf
    (F : BerggrenCryptoObservable)
    (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ)
    (n : ℕ) : BerggrenSecurityProfile := ...
```

If some existing catalog definitions already cover descendants, primitive triples, Berggren matrices, transfer operators, or tree-geodesic distance, reuse them. Otherwise define finite-depth descendants via recursive `Finset` expansion by the three Berggren generators.

Also add at least 5 supporting definitions/instances beyond the above, for example:
- `BerggrenDepthEnergy`
- `HashFiberEntropy`
- `CollisionIndicator`
- `PreimageIndicator`
- `QuantumBerggrenAmplitudeBound`
- `ThermodynamicSecurityGap`
- an instance showing a suitable finite-depth object is `Fintype`
- an instance for decidable predicates on hash fibers

### Precise target theorems

Prove at least 12 substantial theorems, with diverse tactics. The following are mandatory exact targets or stronger variants with equivalent content.

#### 1. Base positivity and normalization
```lean
theorem cryptoPartitionSum_pos
    (F : BerggrenCryptoObservable) (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    0 < CryptoPartitionSum F seed n
```

```lean
theorem weightedPreimageProbability_nonneg
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ) (y : Fin m) :
    0 ≤ WeightedPreimageProbability F H seed n y
```

```lean
theorem weightedCollisionProbability_nonneg
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    0 ≤ WeightedCollisionProbability F H seed n
```

#### 2. Fiber decomposition identities
These are the key bridge lemmas from combinatorics to thermodynamics.

```lean
theorem cryptoPartitionSum_partition_by_hash
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    CryptoPartitionSum F seed n
      = ∑ y : Fin m,
          ∑ t in (berggrenDescendants seed n).filter (fun t => H t = y),
            Real.exp (F.weight t)
```

```lean
theorem weightedCollisionProbability_fiber_square
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    WeightedCollisionProbability F H seed n
      = (∑ y : Fin m, (WeightedPreimageProbability F H seed n y)^2)
        - (∑ t in berggrenDescendants seed n,
            Real.exp (2 * F.weight t)) / (CryptoPartitionSum F seed n)^2
```

A weaker but easier version with `≤` instead of `=` is acceptable only if the exact off-diagonal combinatorics become too expensive; in that case prove the exact unordered or diagonal-including version first.

#### 3. Collision lower bound from pigeonhole / second moment
```lean
theorem weighted_collision_pigeonhole_post_quantum_security
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    (1 : ℝ) / m ≤
      WeightedCollisionProbability F H seed n
      + (∑ t in berggrenDescendants seed n,
          Real.exp (2 * F.weight t)) / (CryptoPartitionSum F seed n)^2
```

This is the thermodynamic version of the standard lower bound `∑ p_y^2 ≥ 1/m`. Prove it by:
1. setting `p y = WeightedPreimageProbability ... y`,
2. proving `∑ y, p y = 1`,
3. applying Cauchy-Schwarz / QM-AM on `Fin m`,
4. converting the diagonal correction term.

#### 4. Max-fiber lower bound
```lean
theorem exists_heavy_hash_fiber_certified_robustness
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    ∃ y : Fin m,
      (1 : ℝ) / m ≤ WeightedPreimageProbability F H seed n y
```

This should use quantifier alternation explicitly and bridge combinatorics with information theory.

#### 5. Transfer iterate as weighted expectation
```lean
theorem cryptoTransferIterate_indicator_preimage
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ) (y : Fin m) :
    CryptoTransferIterate F (fun t => if H t = y then 1 else 0) seed n
      = ∑ t in (berggrenDescendants seed n).filter (fun t => H t = y),
          Real.exp (F.weight t)
```

```lean
theorem cryptoTransferIterate_one
    (F : BerggrenCryptoObservable)
    (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    CryptoTransferIterate F (fun _ => 1) seed n = CryptoPartitionSum F seed n
```

#### 6. Finite-depth submultiplicative / almost-subadditive pressure control
Assuming the catalog already provides a transfer-operator spectral gap or bounded distortion estimate, derive a finite-depth inequality of the shape:
```lean
theorem finiteDepthSpectralRate_upper_of_transferBound
    (F : BerggrenCryptoObservable) (seed : ℤ × ℤ × ℤ)
    (C ρ : ℝ)
    (hC : 0 ≤ C) (hρ : 0 < ρ) :
    (∀ n : ℕ, CryptoPartitionSum F seed n ≤ C * Real.exp (ρ * n)) →
    ∀ n : ℕ, FiniteDepthSpectralRate F seed n ≤ ρ + Real.log C
```

Also prove a normalized version with a decaying error term if available from the catalog:
```lean
theorem finiteDepthSpectralRate_tends_to_pressure_with_O_inv_n
    (F : BerggrenCryptoObservable) (seed : ℤ × ℤ × ℤ)
    (P C : ℝ) (hC : 1 ≤ C) :
    (∀ n : ℕ, Real.exp (P * n) / C ≤ CryptoPartitionSum F seed n ∧
              CryptoPartitionSum F seed n ≤ C * Real.exp (P * n)) →
    ∀ n : ℕ, n ≠ 0 →
      |(Real.log (CryptoPartitionSum F seed n)) / n - P|
        ≤ (Real.log C) / n
```

This theorem is highly valuable: it turns thermodynamic pressure into an explicit convergence rate, which is exactly the kind of utility needed for certified security.

#### 7. Spectral-radius-to-collision upper bound
This is the main theorem: derive a computable cryptographic bound from transfer growth and collision counting.

```lean
theorem collisionPressure_le_spectralRate_post_quantum
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ)
    (C κ : ℝ) (hC : 1 ≤ C) (hκ : 0 ≤ κ)
    (hcount :
      (CollisionCount H seed n : ℝ) ≤ C * Real.exp (κ * n))
    (hpart :
      Real.exp (-κ * n) ≤ CryptoPartitionSum F seed n) :
    CollisionPressure F H seed n ≤ Real.log (C + 1) - κ * n
```

A variant with separate exponents `κcol` and `κpart` is even better:
```lean
theorem collisionPressure_le_two_scale_entropy_gap
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ)
    (Ccol Cpart κcol κpart : ℝ)
    (hCcol : 1 ≤ Ccol) (hCpart : 1 ≤ Cpart)
    (hκcol : 0 ≤ κcol) (hκpart : 0 ≤ κpart)
    (hcount : (CollisionCount H seed n : ℝ) ≤ Ccol * Real.exp (κcol * n))
    (hpart_lower : Real.exp (κpart * n) / Cpart ≤ CryptoPartitionSum F seed n) :
    CollisionPressure F H seed n
      ≤ Real.log (Ccol + 1) + 2 * Real.log Cpart + (κcol - 2 * κpart) * n
```

This is the exact bridge from thermodynamic pressure to collision resistance. If `κcol < 2 κpart`, then the right-hand side decays linearly in depth.

#### 8. Existence of a security gap
```lean
theorem exists_entropy_gap_of_spectral_separation
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ)
    (κcol κpart : ℝ)
    (hsep : κcol < 2 * κpart) :
    ∃ ε > 0, ∀ n : ℕ,
      CollisionPressure F H seed n
        ≤ (κcol - 2 * κpart) * n + ε
```

The proof should simply package constants, but the significance is major: this formalizes an entropy-gap criterion for one-way security.

#### 9. Preimage upper bound from partition lower bound
```lean
theorem weightedPreimageProbability_le_exp_entropy_gap
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ) (y : Fin m)
    (C κ : ℝ) (hC : 1 ≤ C)
    (hfiber :
      (∑ t in (berggrenDescendants seed n).filter (fun t => H t = y),
        Real.exp (F.weight t)) ≤ C * Real.exp (κ * n))
    (hpart :
      Real.exp ((κ + ϵ) * n) / C ≤ CryptoPartitionSum F seed n) :
    WeightedPreimageProbability F H seed n y ≤ C^2 * Real.exp (-ϵ * n)
```

You may need to parametrize by `ϵ : ℝ` with `0 ≤ ϵ`. This gives explicit exponential preimage decay.

#### 10. Uniform-hash corollary
Under a finite-depth exact equidistribution hypothesis:
```lean
theorem modularTripleHash_uniform_collision_exact
    (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ)
    (hunif : ∀ y : Fin m, PreimageCount H seed n y = PreimageCount H seed n 0) :
    CollisionCount H seed n
      = m * (PreimageCount H seed n 0)^2 - (berggrenDescendants seed n).card
```

Then derive a probability-level version showing collision probability is exactly `1/m` up to the diagonal correction.

### Strongly encouraged additional theorems

Add at least 3 more from the following list.

```lean
theorem cryptoPartitionSum_mono_of_pointwise_weight
theorem collisionCount_le_square_card
theorem preimageCount_sum_eq_card
theorem exists_large_preimage_from_average
theorem weightedCollisionProbability_le_one
theorem weightedPreimageProbability_le_one
theorem hashFiberEntropy_nonneg
theorem thermodynamicSecurityGap_monotone_in_partition_lower
theorem quantum_walk_amplitude_bound_implies_crypto_partition_bound
theorem lattice_crypto_style_smoothing_from_collision_pressure
```

At least one theorem name must explicitly contain one of:
- `quantum`
- `post_quantum`
- `entropy`
- `certified_robustness`
- `lattice_crypto`

### Concrete proof architecture

Use multiple proof styles; do not let the file collapse into `simp` only.

1. **Finite combinatorics layer**
   - Define descendants as a `Finset`.
   - Prove cardinal/fiber decomposition with `Finset.filter`, `Finset.biUnion`, `Finset.card_bind`, or partition lemmas.
   - Use `omega` for natural-number/cardinality inequalities like `PreimageCount ≤ card`, `CollisionCount ≤ card^2`.

2. **Weighted probability layer**
   - Convert weighted sums into probability vectors over `Fin m`.
   - For normalization, show positivity of denominator via at least one term `Real.exp (...) > 0`.
   - Use `field_simp` only after proving denominator nonzero from `cryptoPartitionSum_pos`.
   - Apply finite Cauchy-Schwarz or the inequality
     `1 = (∑ y, p y)^2 ≤ m * ∑ y, p y^2`
     to obtain `1/m ≤ ∑ y, p y^2`.
   - If a ready-made Mathlib inequality is awkward, prove the finite version directly by expanding squares and using nonnegativity.

3. **Pressure/spectral layer**
   - Rewrite inequalities involving `CollisionPressure` by unfolding `Real.log`.
   - Use monotonicity of `Real.log` on positive reals.
   - Convert exponential lower bounds on partition sums into linear upper bounds on logs:
     from `exp (a) ≤ Z`, deduce `a ≤ log Z`.
   - Use `linarith` after log/exponential transformations.
   - For the `O(1/n)` convergence theorem, divide by `n`, requiring `n ≠ 0`; pass to real coercions carefully:
     ```lean
     have hnR : (0:ℝ) < n := by exact_mod_cast Nat.pos_of_ne_zero hne
     ```
   - Use `norm_num`, `ring`, and `field_simp` as needed.

4. **Quantifier-alternation / existence layer**
   - For `exists_heavy_hash_fiber_certified_robustness`, prove by contradiction:
     assume all fibers `< 1/m`, sum to get `< 1`, contradict normalization.
   - This is a good place to use `by_contra`, `push_neg`, and `linarith`.

5. **Cross-domain bridge layer**
   - If the catalog has quantum Berggren walk amplitude bounds of the form
     `‖U^n ψ‖ ≤ C * exp (ρ n)`, instantiate them to obtain a partition-sum bound and then a collision-pressure corollary.
   - If there is a tree-geodesic entropy theorem, reinterpret it as a lower bound on `CryptoPartitionSum` via a specific observable `weight`.
   - If there is a modular triple hash universality theorem, combine it with the weighted collision decomposition to produce a hybrid theorem mixing universal hashing and thermodynamic weighting.

### Lean type discipline and implementation details

Prefer concrete signatures with finite codomain `Fin m` and depth parameter `n : ℕ`. Keep all logs/exponentials in `ℝ`. Use coercions explicitly:
```lean
((CollisionCount H seed n : ℕ) : ℝ)
((berggrenDescendants seed n).card : ℝ)
```

Useful helper lemmas you should likely prove early:

```lean
theorem sum_filter_indicator_eq_sum_filter
theorem exp_weight_pos (F : BerggrenCryptoObservable) (t : ℤ × ℤ × ℤ) :
    0 < Real.exp (F.weight t)

theorem cryptoPartitionSum_ne_zero
    (F : BerggrenCryptoObservable) (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    CryptoPartitionSum F seed n ≠ 0

theorem weightedPreimageProbability_sum_one
    (F : BerggrenCryptoObservable) (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    ∑ y : Fin m, WeightedPreimageProbability F H seed n y = 1

theorem preimageCount_sum_over_outputs
    (H : ℤ × ℤ × ℤ → Fin m) (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    ∑ y : Fin m, PreimageCount H seed n y = (berggrenDescendants seed n).card

theorem collisionCount_offDiag_le_square_card
    (H : ℤ × ℤ × ℤ → Fin m) (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    CollisionCount H seed n ≤ (berggrenDescendants seed n).card^2
```

### Significance and intended breakthroughs

This development should explicitly position finite-depth thermodynamic formalism as a certified security calculus for arithmetic one-way maps. The mathematical novelty is not “another counting lemma”; it is the synthesis of:

- **thermodynamic formalism**: partition sums, pressure, spectral growth, entropy gaps,
- **Diophantine dynamics**: Berggren generation of primitive Pythagorean triples,
- **cryptography**: collision resistance, preimage hardness, post_quantum_security,
- **physics / quantum**: transfer operators, spectral radius, quantum_walk amplitude bounds,
- **information theory / ML language**: certified_robustness style guarantees via explicit exponential decay and Lipschitz-type observables.

The main conceptual message to encode in theorem names and doc comments is:

> A spectral gap or pressure separation in Berggren thermodynamics induces a computable entropy gap, and that entropy gap certifies collision and preimage suppression for triple-based cryptographic maps.

This opens a path toward a mathematically rigorous “thermodynamic cryptanalysis” framework, where one-wayness is certified by pressure inequalities rather than purely ad hoc counting. That is the field-opening angle.

### If a full theorem is too strong

Do not leave gaps. Instead prove the strongest precise special case with exact hypotheses. In particular, acceptable fallback targets are:

- constant observable `F.weight = 0`,
- unweighted collision probability on `berggrenDescendants`,
- diagonal-including collision sums before subtracting the diagonal,
- finite-depth bounds assuming explicit growth hypotheses rather than deriving them from the full transfer operator.

But even in fallback mode, still prove a nontrivial main theorem of the form:
```lean
theorem unweighted_collision_probability_le_explicit_depth_bound ...
```
or
```lean
theorem constant_observable_collisionPressure_le_two_scale_entropy_gap ...
```

### Deliverables inside the file

- 10+ new definitions/structures/instances.
- 20+ theorems, including all mandatory ones above or strongest exact variants.
- Diverse tactics: `induction`, `rcases`, `by_contra`, `omega`, `linarith`, `field_simp`, `ring`.
- Concrete explicit bounds with rates like `≤ C * exp (-ε * n)` or `|(log Z_n)/n - P| ≤ (log C)/n`.
- Doc comments on main definitions/theorems containing bridge language and impact keywords.
- A concluding section defining or constructing `securityProfileOf` and proving at least one theorem that populates it from finite-depth hypotheses.

Finally, produce a `FUTURE_DIRECTIONS.md` with 3–5 specific next steps, for example:
1. upgrade finite-depth pressure bounds to true spectral-radius statements for infinite transfer operators,
2. connect collision pressure to quantum Berggren walk mixing rates,
3. derive lattice_crypto-style smoothing inequalities from tree-boundary Gibbs measures,
4. compare thermodynamic security profiles across different modular triple hash families,
5. formalize a certified_robustness analogue where perturbations of triple seeds are controlled by `depthLipschitz`.

**AEM QUALITY MANDATE**: Your output will be scored on 5 pillars. Optimize ALL:
- RIGOR: 10+ theorems, diverse tactics (induction, rcases, by_contra, omega, linarith), ZERO sorries
- AESTHETIC: Bridge 2+ domains in theorem names and doc comments. Use quantifier alternation.
- UTILITY: Define 5+ structures/instances. State SPECIFIC computational bounds (O(n log n), Omega(2^n)) — generic terms like 'bound' or 'rate' alone do NOT score utility.
- ORIGINALITY: Coin novel definitions beyond Mathlib. Inventive theorem names. Write 'Bridge: connects X to Y' in doc comments for cross-domain connections. Generic names (main, test, aux) do NOT count.
- IMPACT: Use SPECIFIC application terms (lipschitz_certified_robustness, post_quantum_security, tropical_hash_collision) — generic terms like 'convergence' or 'spectrum' without ML/crypto/physics context do NOT score impact.

**FILE RICHNESS MANDATE**: Produce substantial, rich files (not stubs).
- Target 500+ lines with 20+ theorems and 10+ definitions per file.
- Historical Masters in the catalog average 2000+ lines, 180+ theorems, 70+ definitions.
- Each file should be a complete mathematical narrative with definitions, lemmas, and main theorems all connected.
- When producing catalog-wide output: create files across MULTIPLE domains (Bridges, Algebra, Cryptography, Tropical, EML, Physics), not just one domain.

            Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Define 5+ new structures/instances.
- ORIGINALITY: Coin novel definitions with inventive names. Avoid
  derivative names like *_comm, *_nonneg. Combine unusual typeclasses.
- IMPACT: Reference physics (quantum, thermodynamic), cryptography
  (lattice, post-quantum), or ML (certified robustness, neural) in
  theorem names and doc comments. Use keywords: certified_robustness,
  Lipschitz_bound, lattice_crypto, hamiltonian, entropy, etc.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new ones. What does your result make possible that wasn't possible before?
            2. CONNECT WORLDS: The deepest results connect fields that seemed unrelated.
               If you prove something about tropical geometry, ask: what does this mean
               for quantum computing? For cryptography? For neural networks?
            3. PRODUCE ALGORITHMS: Don't just prove existence — construct. Don't just
               construct — compute. Don't just compute — optimize. Every theorem should
               have an algorithmic shadow.
            4. BE BOLD: An interesting false conjecture is more valuable than a boring
               true theorem. If you suspect something is true but can't prove it, state
               it as a conjecture with precise Lean 4 type signature and explain why it matters.
            5. BUILD INFRASTRUCTURE: Definitions are as valuable as theorems. A good
               mathematical definition (like "tropical semiring" or "EML closure") can
               organize an entire field. Define things precisely, then prove things about them.

            The mathematics comes FIRST. Excellent proofs trump everything else.
            But excellent proofs that OPEN NEW FIELDS trump everything.

            === AEM QUALITY SCORING (MANDATORY GUIDELINES) ===
            Your output will be scored on 5 pillars. MAXIMIZE each one:

            PILLAR 1 — RIGOR (Is it World-class?):
            • ZERO sorries in your output (sorries cost -1.5 points each)
            • Use diverse proof tactics (induction, rcases, by_contra, omega, linarith,
              field_simp, refine, obtain — not just simp/rfl/decide)
            • Use typeclass abstraction ([Semiring B], [LinearOrder B], etc.) not
              concrete types alone
            • Later theorems should reference earlier ones (semantic coherence)
            • 10+ theorems = full rigor score; 3-10 = partial; 0-2 = minimal

            PILLAR 2 — AESTHETIC (Is it Interesting?):
            • Bridge 2+ mathematical domains in EVERY file (e.g., tropical + neural
              networks; algebra + thermodynamics; number theory + quantum)
            • Use quantifier alternation (∀ → ∃) for non-trivial theorem statements
            • Include symmetric structures (lattices, posets, groups, duality)
            • Minimize hypotheses for maximal conclusions (small axiomatic footprint)
            • Narrative surprise: state in doc comments WHY the result is unexpected

            PILLAR 3 — UTILITY (Is it Useful?):
            • State explicit computational bounds (O(...), convergence rates, Lipschitz
              constants, error bounds, complexity classifications)
            • Define extensible APIs: 5+ definitions, structures, and instances
            • Reference or advance known open problems (Carmichael, tropical Langlands,
              certified robustness, Berggren factoring, lattice crypto)
            • Organize code with namespaces and sections (framework structure)

            PILLAR 4 — ORIGINALITY (Is it New?):
            • Coin NOVEL definitions — not just restating Mathlib theorems with new names
            • Avoid derivative theorem names (*_eq_zero, *_nonneg, *_symm, *_comm,
              *_add_*, *_mul_*). Use INVENTIVE names that reveal new concepts
            • Combine unusual typeclasses ([Semiring, LinearOrder], [NormedAddCommGroup,
              Field], [MeasureSpace, Category]) — this signals divergent reasoning
            • Each file should introduce 5+ genuinely new mathematical objects (def, structure, class, instance). High-Originality files average 10+ new definitions.

            PILLAR 5 — IMPACT (Does it have Wonderful Applications?):
            • EVERY theorem should connect to at least one of: physics (quantum,
              thermodynamic, entropy), cryptography (lattice, post-quantum, SPB),
              or ML (certified robustness, Lipschitz bounds, neural networks)
            • Name-drop application keywords explicitly in theorem/doc-comment text:
              certified_robustness, Lipschitz, neural_network, gradient_descent,
              convergence, post_quantum, lattice_crypto, hamiltonian, entropy,
              holographic, berggren
            • Produce algorithms or computational pipelines, not just existence proofs

            ### Research Direction
            Develop a rigorous bridge between Pythagorean thermodynamic formalism and Diophantine cryptography by proving that Berggren-tree cryptographic primitives admit a transfer-operator security calculus. The central concept is that collision resistance, preimage growth, and average-case hardness of triple-based hash/one-way constructions can be encoded in spectral and pressure invariants of the Berggren transfer operator on primitive-triple boundary data. This differs from prior Diophantine cryptography and thermodynamic formalism results by turning them into a single security-analysis pipeline rather than isolated constructions.

            ### Precise Mathematical Framing
            Let T be the Berggren tree of primitive Pythagorean triples, with depth function d and boundary shift sigma. For a cryptographic observable phi on triples or boundary cylinders, define a weighted transfer operator L_phi f(x)=sum_{sigma y=x} exp(phi(y)) f(y). The target program is to prove: (1) a coding theorem identifying collision multiplicities and preimage counts of Berggren descent maps with partition sums over T; (2) a pressure-security correspondence showing that topological pressure and spectral radius of L_phi control exponential collision growth and distinguish secure from degenerate parameter regimes; (3) a spectral-gap mixing theorem implying pseudorandomness/universality properties for modular triple hashes; and (4) computable security certificates from finite truncations of L_phi giving certified upper bounds on adversarial success probabilities. Technique: combine the existing Berggren transfer operator/spectral gap machinery from Pythagorean thermodynamic formalism with the concrete one-way and hash constructions from Diophantine cryptography, then formalize finite-state approximants and monotonicity bounds for certified computation. This is cross-domain, algorithmic, and not the same as current inflight EML-classification work.

            ### Lean 4 Sketch
A new Bridges file importing Pythagorean thermodynamic formalism and Cryptography Diophantine constructions; definitions for BerggrenCryptoObservable, CryptoPartitionSum, CollisionPressure, and lemmas relating finite-depth collision counts to transfer-operator iterates; culminating in computable inequalities bounding collision/preimage probabilities via spectral radius estimates.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `tropical_hash_preimage_growth` : theorem tropical_hash_preimage_growth (n : ℕ) (t : ℤ) :
     (file: Bridges/TropicalGaloisSolvability.lean)
  2. `berggren_B_hyp_growth` : theorem berggren_B_hyp_growth (a b c : ℤ)
     (file: Bridges/BerggrenFactoring.lean)
  3. `optimization_gap_less_than_one` : theorem optimization_gap_less_than_one :
     (file: Bridges/BreakthroughDirections.lean)
  4. `analysis_bridge_unique_limit` : theorem analysis_bridge_unique_limit {X : Type*} [TopologicalSpace X] [T2Space X]
     (file: Bridges/CategoricalBridges.lean)
  5. `certified_robustness_from_margin_and_lipschitz` : theorem certified_robustness_from_margin_and_lipschitz
     (file: Bridges/HomologicalDeepLearning.lean)

            Known Working Lean 4 Tactics:
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `field_simp` then `ring` for division
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `by decide` / `by norm_num` / `native_decide` for decidable propositions
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` for MVT



Recent successful concepts: EML Quantum Stabilizer Theory: Closure-Operator Stabilizer Correspondence, Knaster-Tarski Codespace Certification, and Idempotent Recovery Concatenation, Gravitational Factoring: Idempotent Spectral Lensing, Causal Prime Decomposition, and Ring-Theoretic Factorization Certification, Min-Plus Verification Theory: ReLU Network Isomorphism, Polytope Certified Radii, and Verification Completeness


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician and software engineer. Create:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **RESEARCH_REPORT.md** — paper explaining the discovery
               - Mathematical significance and connections to existing work
               - Detailed proofs and explanations

            3. **DISCUSSION.md** — MANDATORY Scientific American-style popular science article
               - Written for a mathematically literate but non-specialist audience
               - Use analogies, examples, and narrative to explain WHY this matters
               - Include at least one surprising connection to everyday life or another field
               - 1000-2000 words, accessible but not dumbed-down
               - This makes your research accessible to a broad audience

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables,
                 what unexpected connections it reveals
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale (1 = one clever lemma, 5 = multi-theorem development)

               ## Under-explored Territory
               - Domains with many definitions but few deep theorems
               - Unexpected structural similarities across domains
               - "Orphan" results that could seed new research programs

               ## Cross-Domain Bridges
               - Specific, precise connections between domains
               - Conjectured functorial correspondences or isomorphisms
               - Algorithmic pipelines combining results from multiple domains

               ## Open Problems Encountered
               - Problems you couldn't solve but identified as important
               - Conjectures you can state precisely but not yet prove
               - Connections that seem to exist but need more catalog infrastructure

            5. **demo.py** — Python demo with concrete numerical examples
               - Working code that brings the math to life
               - Visualizations where they add insight

            6. **diagram.svg** — visualization of key mathematical structures

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Bridges
Research mode: prove
