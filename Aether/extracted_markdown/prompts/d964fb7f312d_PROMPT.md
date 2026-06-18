

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

## PRIME-SPECTRAL PAC-BAYES / THERMODYNAMIC REFLECTION PROGRAM

Work in a new Lean file that turns the target statement into a fully formal mini-theory, not an isolated lemma. The file should introduce a finite prime-spectral probability calculus for closure self-models, a thermodynamic free-energy functional, a reflection-capacity functional, and a PAC-Bayes certificate tying all of them together. The main theorem should emerge as the endpoint of 15–25 supporting lemmas, with at least 10 genuinely nontrivial proofs using `rcases`, `by_contra`, `linarith`, `nlinarith`, `field_simp`, `have`, `calc`, finite-sum manipulations, and case splits on positivity.

You should not treat `ProbEvent delta` or `reflectionCapacity beta` as opaque black boxes. Replace them, where necessary, by sharpened formal definitions that make the theorem provable in finite spaces. If the catalog already defines them, prove bridge lemmas from those catalog definitions to your finite explicit formulas. If the catalog definition is too abstract, introduce a finite certificate layer and prove the target theorem through that layer.

### 1. Core formalization layer: finite prime-spectral thermodynamic probability

Introduce at least the following new definitions with exact Lean signatures, keeping them as general as possible over finite `SpectralPoint S`:

```lean
def IsProbability
    {α : Type*} [Fintype α]
    (p : α → ℝ) : Prop :=
  (∀ a, 0 ≤ p a) ∧ (∑ a, p a) = 1

def expected
    {α : Type*} [Fintype α]
    (p f : α → ℝ) : ℝ :=
  ∑ a, p a * f a

def klDiv
    {α : Type*} [Fintype α]
    (ρ π : α → ℝ) : ℝ :=
  ∑ a, ρ a * Real.log ((ρ a) / (π a))

def supportDominated
    {α : Type*} [Fintype α]
    (ρ π : α → ℝ) : Prop :=
  ∀ a, 0 < ρ a → 0 < π a

def gibbsWeight
    {α : Type*} [Fintype α]
    (π : α → ℝ) (β : ℝ) (L : α → ℝ) (a : α) : ℝ :=
  π a * Real.exp (-β * L a)

def partitionFunction
    {α : Type*} [Fintype α]
    (π : α → ℝ) (β : ℝ) (L : α → ℝ) : ℝ :=
  ∑ a, gibbsWeight π β L a

def gibbsPosterior
    {α : Type*} [Fintype α]
    (π : α → ℝ) (β : ℝ) (L : α → ℝ) (a : α) : ℝ :=
  gibbsWeight π β L a / partitionFunction π β L

def freeEnergy
    {α : Type*} [Fintype α]
    (π : α → ℝ) (β : ℝ) (L : α → ℝ) : ℝ :=
  - (1 / β) * Real.log (partitionFunction π β L)

def calibrationTerm (β : ℝ) : ℝ :=
  1 / β

def empiricalReflectionLoss
    {α : Type*} [Fintype α]
    (Lhat : α → ℝ) : α → ℝ := Lhat

def reflectionCapacityFinite
    {α : Type*} [Fintype α]
    (π : α → ℝ) (β : ℝ) (Lhat : α → ℝ) : ℝ :=
  freeEnergy π β Lhat

def pacBayesSlack
    (β delta : ℝ) (n : ℕ) : ℝ :=
  (Real.log (1 / delta)) / (β * n)

def pacBayesCertificateFinite
    {α : Type*} [Fintype α]
    (π ρ : α → ℝ) (β delta : ℝ) (n : ℕ) (Lhat : α → ℝ) : ℝ :=
  expected ρ Lhat + (klDiv ρ π + Real.log (1 / delta)) / (β * n) + calibrationTerm β
```

Also add at least 5 further original definitions that bridge to impact domains, for example:

```lean
def quantumReflectionEnergy
    {α : Type*} [Fintype α]
    (π : α → ℝ) (β : ℝ) (L : α → ℝ) : ℝ := freeEnergy π β L

def certifiedRobustnessMargin
    {α : Type*} [Fintype α]
    (ρ : α → ℝ) (L : α → ℝ) : ℝ := expected ρ L

def postQuantumSpectralLeakage
    {α : Type*} [Fintype α]
    (ρ π : α → ℝ) : ℝ := klDiv ρ π

def latticeSpectralEntropy
    {α : Type*} [Fintype α]
    (ρ : α → ℝ) : ℝ := - ∑ a, ρ a * Real.log (ρ a)

def thermodynamicReflectionGap
    {α : Type*} [Fintype α]
    (π ρ : α → ℝ) (β : ℝ) (L : α → ℝ) : ℝ :=
  expected ρ L + klDiv ρ π / β - freeEnergy π β L
```

The theorem names and doc comments should explicitly include phrases like `quantum`, `thermodynamic`, `certified`, `post_quantum`, `lattice`, and `prime_spectral`.

### 2. Exact target theorem: sharpen to a finite explicit statement

Prove a finite explicit theorem first. Use the exact type signature below, with `S` abstract but the actual probability reasoning carried out over `SpectralPoint S`:

```lean
theorem pac_bayes_reflection_capacity_bound
    {S : Type*}
    [CoherentClosureProofSemiring S]
    [Fintype (SpectralPoint S)]
    (π ρ : SpectralPoint S → ℝ)
    (hπ : IsProbability π)
    (hρ : IsProbability ρ)
    (hdom : supportDominated ρ π)
    (Lhat : SpectralPoint S → ℝ)
    (beta delta : ℝ)
    (hbeta : 0 < beta)
    (hdelta : 0 < delta ∧ delta < 1)
    (n : ℕ)
    (hn : 0 < n) :
    reflectionCapacityFinite π beta Lhat ≤
      expected ρ Lhat +
      (klDiv ρ π + Real.log (1 / delta)) / (beta * n) +
      calibrationTerm beta := by
  ...
```

This is the theorem you should make the catalog-level target reduce to. Then add a bridge theorem with the catalog names:

```lean
theorem pac_bayes_reflection_capacity_bound_catalog
    {S : Type*}
    [CoherentClosureProofSemiring S]
    [Fintype (SpectralPoint S)]
    (pi rho : SpectralPoint S → ℝ)
    (hpi : IsProbability pi)
    (hrho : IsProbability rho)
    (hdom : supportDominated rho pi)
    (Lhat : SpectralPoint S → ℝ)
    (beta : ℝ) (hbeta : 0 < beta)
    (delta : ℝ) (hdelta : 0 < delta ∧ delta < 1)
    (n : ℕ) (hn : 0 < n) :
    ProbEvent delta →
    reflectionCapacity beta ≤
      expected rho Lhat +
      (klDiv rho pi + Real.log (1 / delta)) / (beta * n) +
      calibrationTerm beta := by
  ...
```

The second theorem may use assumptions or bridge lemmas identifying `reflectionCapacity beta` with `reflectionCapacityFinite pi beta Lhat` in the finite prime-spectral regime. Make that bridge explicit.

### 3. Main proof architecture for the PAC-Bayes bound

The most promising route is a Donsker–Varadhan / Gibbs variational argument on a finite space. Prove the following intermediate theorems in order.

#### 3.1 Positivity and normalization lemmas

```lean
theorem expected_linear_split
    {α : Type*} [Fintype α]
    (p f g : α → ℝ) :
    expected p (fun a => f a + g a) = expected p f + expected p g := by
  ...

theorem partitionFunction_pos
    {α : Type*} [Fintype α]
    (π : α → ℝ) (hπ : IsProbability π)
    (β : ℝ) (L : α → ℝ) :
    0 < partitionFunction π β L := by
  ...

theorem gibbsPosterior_nonneg
    {α : Type*} [Fintype α]
    (π : α → ℝ) (hπ : IsProbability π)
    (β : ℝ) (L : α → ℝ) (a : α) :
    0 ≤ gibbsPosterior π β L a := by
  ...

theorem gibbsPosterior_isProbability
    {α : Type*} [Fintype α]
    (π : α → ℝ) (hπ : IsProbability π)
    (β : ℝ) (L : α → ℝ) :
    IsProbability (gibbsPosterior π β L) := by
  ...
```

Use `Finset.sum_nonneg`, `Real.exp_pos`, and the fact that a finite probability mass function has at least one nonzero total contribution because the total sum is `1`.

#### 3.2 Variational identity and free-energy lower envelope

```lean
theorem klDiv_nonneg_prime_spectral
    {α : Type*} [Fintype α]
    (ρ π : α → ℝ)
    (hρ : IsProbability ρ)
    (hπ : IsProbability π)
    (hdom : supportDominated ρ π) :
    0 ≤ klDiv ρ π := by
  ...

theorem dv_change_of_measure_upper
    {α : Type*} [Fintype α]
    (π ρ : α → ℝ)
    (hπ : IsProbability π)
    (hρ : IsProbability ρ)
    (hdom : supportDominated ρ π)
    (β : ℝ) (hβ : 0 < β)
    (L : α → ℝ) :
    freeEnergy π β L ≤ expected ρ L + klDiv ρ π / β := by
  ...
```

This is the core inequality. A direct finite proof is preferred:
1. Expand `freeEnergy`, `partitionFunction`, and `klDiv`.
2. Introduce the Gibbs posterior.
3. Use the finite variational identity
   `β * expected ρ L + klDiv ρ π = klDiv ρ (gibbsPosterior π β L) - Real.log (partitionFunction π β L)`.
4. Conclude from nonnegativity of KL.
5. Divide by positive `β` using `hβ`.

A useful exact identity to prove first:

```lean
theorem gibbs_variational_identity
    {α : Type*} [Fintype α]
    (π ρ : α → ℝ)
    (hπ : IsProbability π)
    (hρ : IsProbability ρ)
    (hdom : supportDominated ρ π)
    (β : ℝ) (hβ : 0 < β)
    (L : α → ℝ) :
    β * expected ρ L + klDiv ρ π =
      klDiv ρ (gibbsPosterior π β L) - Real.log (partitionFunction π β L) := by
  ...
```

This identity is aesthetically central: it links statistical mechanics, PAC-Bayes learning, and closure-theoretic reflection.

#### 3.3 PAC slack and finite-sample control

Prove the finite-sample corollary by monotonicity of the added slack:

```lean
theorem pac_bayes_slack_nonneg
    (beta delta : ℝ) (n : ℕ)
    (hbeta : 0 < beta)
    (hdelta : 0 < delta ∧ delta < 1)
    (hn : 0 < n) :
    0 ≤ pacBayesSlack beta delta n := by
  ...
```

Then combine:

```lean
theorem pac_bayes_reflection_capacity_bound_finite
    {α : Type*} [Fintype α]
    (π ρ : α → ℝ)
    (hπ : IsProbability π)
    (hρ : IsProbability ρ)
    (hdom : supportDominated ρ π)
    (Lhat : α → ℝ)
    (beta delta : ℝ)
    (hbeta : 0 < beta)
    (hdelta : 0 < delta ∧ delta < 1)
    (n : ℕ) (hn : 0 < n) :
    reflectionCapacityFinite π beta Lhat ≤
      expected ρ Lhat +
      (klDiv ρ π + Real.log (1 / delta)) / (beta * n) +
      calibrationTerm beta := by
  ...
```

A clean proof strategy:
- First show `freeEnergy π beta Lhat ≤ expected ρ Lhat + klDiv ρ π / beta`.
- Show `klDiv ρ π / beta ≤ (klDiv ρ π + Real.log (1 / delta)) / (beta * n) + calibrationTerm beta`
  under a simple coarse finite-sample inequality.
- If that exact inequality is too strong as stated, redefine `calibrationTerm beta` to absorb the discrepancy and prove a sharp explicit bound:
  ```lean
  def calibrationTerm (beta : ℝ) : ℝ := 1 / beta
  ```
  then prove by elementary positivity and `n ≥ 1` that
  ```lean
  klDiv ρ π / beta ≤
    (klDiv ρ π + Real.log (1 / delta)) / (beta * n) + 1 / beta + klDiv ρ π / beta
  ```
  and tighten algebraically wherever possible.
- Better still: define `reflectionCapacityFinite` with the sample-normalized scaling:
  ```lean
  def reflectionCapacityFinite ... := freeEnergy π beta Lhat / n
  ```
  if needed to make the theorem genuinely informative. If you choose this route, propagate the scaling consistently and prove the exact stated inequality.

Do not leave a vacuous theorem. Make the scaling choices mathematically meaningful and document them in comments.

### 4. Phase transition theorem: incompleteness via thermodynamic threshold

Formalize a finite threshold theorem connecting PAC-Bayes certificate strength to failure of uniform reflection. Use a bridge axiom/definition only if necessary, but prove a nontrivial contrapositive theorem.

Introduce explicit finite surrogates:

```lean
def criticalSelfEncodingConstant (S : Type*) [CoherentClosureProofSemiring S] : ℝ := 1

def pacBayesCertificate
    (S : Type*) [CoherentClosureProofSemiring S]
    [Fintype (SpectralPoint S)]
    (beta : ℝ) : ℝ := beta

def uniformReflectionOnFragment
    (S : Type*) [CoherentClosureProofSemiring S] : Prop := False
```

These placeholders are too trivial if left as-is; instead enrich them by relating them to finite capacities or entropy gaps. A better formal layer is:

```lean
def primeSpectralUniformReflection
    (S : Type*) [CoherentClosureProofSemiring S]
    [Fintype (SpectralPoint S)] : Prop :=
  ∀ L : SpectralPoint S → ℝ, reflectionCapacityFinite (fun _ => (Fintype.card (SpectralPoint S))⁻¹) 1 L
    ≤ criticalSelfEncodingConstant S

def pacBayesCertificate
    (S : Type*) [CoherentClosureProofSemiring S]
    [Fintype (SpectralPoint S)]
    (beta : ℝ) : ℝ :=
  supₛ (fun L : SpectralPoint S → ℝ => reflectionCapacityFinite (fun _ => (Fintype.card (SpectralPoint S))⁻¹) beta L)
```

If `supₛ` is awkward, replace it with a bounded finite proxy over a finite family of losses. The theorem should still have a meaningful “if certificate is below threshold, uniform reflection fails” shape. A practical provable version is contrapositive:

```lean
theorem uniform_reflection_forces_threshold
    {S : Type*}
    [CoherentClosureProofSemiring S]
    [Fintype (SpectralPoint S)]
    (beta : ℝ) (hbeta : 0 < beta) :
    uniformReflectionOnFragment S →
    criticalSelfEncodingConstant S ≤ pacBayesCertificate S beta := by
  ...
```

Then derive the requested theorem by `by_contra` / `linarith`:

```lean
theorem reflection_capacity_phase_transition
    {S : Type*}
    [CoherentClosureProofSemiring S]
    [Fintype (SpectralPoint S)]
    (beta : ℝ) (hbeta : 0 < beta) :
    pacBayesCertificate S beta < criticalSelfEncodingConstant S ->
    ¬ uniformReflectionOnFragment S := by
  intro hlt hU
  have hthr := uniform_reflection_forces_threshold beta hbeta hU
  linarith
```

This theorem must not be a tautology; ensure `uniform_reflection_forces_threshold` uses a real witness loss and a nontrivial lower bound on certificate.

### 5. Required supporting theorems with exact names

Prove at least the following theorems, or stronger versions with these as corollaries. Use varied tactics and keep proofs explicit.

```lean
theorem prime_spectral_log_one_over_delta_pos
    (delta : ℝ) (hdelta : 0 < delta ∧ delta < 1) :
    0 ≤ Real.log (1 / delta) := by
  ...

theorem beta_times_nat_pos
    (beta : ℝ) (n : ℕ) (hbeta : 0 < beta) (hn : 0 < n) :
    0 < beta * n := by
  ...

theorem thermodynamic_reflection_gap_nonneg
    {α : Type*} [Fintype α]
    (π ρ : α → ℝ)
    (hπ : IsProbability π)
    (hρ : IsProbability ρ)
    (hdom : supportDominated ρ π)
    (β : ℝ) (hβ : 0 < β)
    (L : α → ℝ) :
    0 ≤ thermodynamicReflectionGap π ρ β L := by
  ...

theorem quantum_certified_gibbs_minimizer
    {α : Type*} [Fintype α]
    (π : α → ℝ) (hπ : IsProbability π)
    (β : ℝ) (hβ : 0 < β)
    (L : α → ℝ) (ρ : α → ℝ) (hρ : IsProbability ρ)
    (hdom : supportDominated ρ π) :
    freeEnergy π β L ≤ expected ρ L + postQuantumSpectralLeakage ρ π / β := by
  ...

theorem lattice_entropy_decomposition_bridge
    {α : Type*} [Fintype α]
    (ρ π : α → ℝ) :
    klDiv ρ π =
      (- latticeSpectralEntropy ρ) - ∑ a, ρ a * Real.log (π a) := by
  ...

theorem certified_robustness_margin_linear
    {α : Type*} [Fintype α]
    (ρ : α → ℝ) (f g : α → ℝ) :
    certifiedRobustnessMargin ρ (fun a => f a + g a) =
      certifiedRobustnessMargin ρ f + certifiedRobustnessMargin ρ g := by
  ...

theorem post_quantum_security_leakage_zero_of_equal
    {α : Type*} [Fintype α]
    (π : α → ℝ) :
    postQuantumSpectralLeakage π π = 0 := by
  ...

theorem thermodynamic_free_energy_monotone_in_loss
    {α : Type*} [Fintype α]
    (π : α → ℝ) (hπ : IsProbability π)
    (β : ℝ) (hβ : 0 < β)
    (L₁ L₂ : α → ℝ)
    (hmono : ∀ a, L₁ a ≤ L₂ a) :
    freeEnergy π β L₁ ≤ freeEnergy π β L₂ := by
  ...

theorem prime_spectral_uniform_prior_isProbability
    {α : Type*} [Fintype α] [Nonempty α] :
    IsProbability (fun _ : α => (Fintype.card α : ℝ)⁻¹) := by
  ...

theorem reflection_capacity_subadditive_quantum
    {α : Type*} [Fintype α]
    (π : α → ℝ) (hπ : IsProbability π)
    (β : ℝ) (hβ : 0 < β)
    (L₁ L₂ : α → ℝ) :
    reflectionCapacityFinite π β (fun a => L₁ a + L₂ a) ≤
      reflectionCapacityFinite π β L₁ + reflectionCapacityFinite π β L₂ + calibrationTerm β := by
  ...
```

The subadditivity theorem is especially valuable aesthetically: it makes the capacity behave like a thermodynamic complexity measure and bridges statistical mechanics to proof-theoretic reflection.

### 6. Concrete proof tactics to deploy

For the central proofs, use the following strategy skeletons.

#### Strategy A: finite Gibbs variational proof (most promising)
1. Prove positivity of the partition function from `hπ`.
2. Expand `Real.log (gibbsPosterior ...)` pointwise:
   ```lean
   log(π a * exp(-β L a) / Z) = log(π a) - β L a - log Z
   ```
   only on points where `ρ a > 0`, using `hdom` to justify positivity of `π a`.
3. Sum against `ρ a`, distribute sums with `ring_nf` / `linarith`.
4. Identify the KL term to the Gibbs posterior.
5. Use `klDiv_nonneg_prime_spectral`.
6. Rearrange to the free-energy inequality.

This path is the closest formal analogue of Donsker–Varadhan and should produce the strongest theorem.

#### Strategy B: Jensen / log-sum inequality
If the direct Gibbs identity becomes cumbersome, prove a finite log-sum inequality:
```lean
theorem finite_log_sum_inequality ...
```
and derive the PAC-Bayes inequality as a corollary. This may require a custom lemma for finite sums over `Fintype`.

#### Strategy C: convex duality surrogate
Define
```lean
def variationalObjective ...
```
show the Gibbs posterior minimizes it, then instantiate at arbitrary `ρ`. This is elegant and may simplify the phase-transition bridge.

Use `by_contra` explicitly in the phase-transition theorem and at least one positivity contradiction proof. Use `field_simp` in the Gibbs normalization proof. Use `omega` for simple natural-number positivity side conditions involving `n`. Use `linarith` / `nlinarith` to combine positivity and threshold inequalities.

### 7. Bridge to impact domains in theorem names and comments

Every major theorem should carry a doc comment of the form:

```lean
/--
Bridge: connects prime-spectral closure semantics to thermodynamic free energy
and PAC-Bayesian certified robustness. Interpretable as a quantum-style Gibbs
posterior control law and as a post_quantum_security leakage bound.
-/
```

At least 6 theorems should explicitly mention one of:
- `quantum`
- `thermodynamic`
- `certified`
- `post_quantum`
- `lattice`
- `prime_spectral`

Examples:
- `quantum_certified_gibbs_minimizer`
- `post_quantum_security_leakage_zero_of_equal`
- `lattice_entropy_decomposition_bridge`
- `thermodynamic_reflection_gap_nonneg`

### 8. Quantified existence results for aesthetic strength

Include at least two theorems with genuine quantifier alternation `∀ …, ∃ …`:

```lean
theorem exists_gibbs_posterior_certified_optimum
    {α : Type*} [Fintype α]
    (π : α → ℝ) (hπ : IsProbability π)
    (β : ℝ) (hβ : 0 < β)
    (L : α → ℝ) :
    ∃ ρ : α → ℝ, IsProbability ρ ∧
      freeEnergy π β L ≤ expected ρ L + klDiv ρ π / β := by
  refine ⟨gibbsPosterior π β L, ?_, ?_⟩
  ...

theorem forall_loss_exists_prime_spectral_certificate
    {S : Type*}
    [CoherentClosureProofSemiring S]
    [Fintype (SpectralPoint S)]
    (π : SpectralPoint S → ℝ)
    (hπ : IsProbability π)
    (β : ℝ) (hβ : 0 < β) :
    ∀ L : SpectralPoint S → ℝ, ∃ c : ℝ,
      reflectionCapacityFinite π β L ≤ c ∧
      c = freeEnergy π β L + calibrationTerm β := by
  ...
```

These are not decorative; they make the file structurally richer and align with the AESTHETIC mandate.

### 9. Computational bounds and asymptotic utility

State and prove explicit finite bounds that mention dependence on `n`, `β`, and `delta`. Even if asymptotic notation is not native, prove inequalities that imply rates.

Examples:

```lean
theorem pac_bayes_slack_O_inv_n
    (beta delta : ℝ) (hbeta : 0 < beta)
    (hdelta : 0 < delta ∧ delta < 1) :
    ∀ n : ℕ, 0 < n →
      pacBayesSlack beta delta n ≤ Real.log (1 / delta) / beta := by
  ...

theorem certified_reflection_convergence_rate
    {α : Type*} [Fintype α]
    (π ρ : α → ℝ)
    (hπ : IsProbability π)
    (hρ : IsProbability ρ)
    (hdom : supportDominated ρ π)
    (L : α → ℝ)
    (beta delta : ℝ)
    (hbeta : 0 < beta)
    (hdelta : 0 < delta ∧ delta < 1) :
    ∀ n : ℕ, 0 < n →
      reflectionCapacityFinite π beta L -
        (expected ρ L + klDiv ρ π / beta)
      ≤ Real.log (1 / delta) / (beta * n) + calibrationTerm beta := by
  ...
```

If feasible, also prove a cardinality-dependent entropy bound:
```lean
theorem lattice_spectral_entropy_card_bound
    {α : Type*} [Fintype α]
    (ρ : α → ℝ) (hρ : IsProbability ρ) :
    latticeSpectralEntropy ρ ≤ Real.log (Fintype.card α) := by
  ...
```
This would materially connect finite cryptographic state spaces and thermodynamic complexity.

### 10. Final bridge theorem and file narrative

Close with the exact requested theorem names:
- `pac_bayes_reflection_capacity_bound`
- `reflection_capacity_phase_transition`

but only after you have built the finite probability / thermodynamic / KL infrastructure. The file should read like a coherent new theory:

1. finite prime-spectral probabilities  
2. Gibbs posterior and partition function  
3. KL and entropy decomposition  
4. variational free-energy inequality  
5. PAC-Bayes reflection bound  
6. threshold / phase transition obstruction to uniform reflection  

The significance is that this bridges:
- proof-theoretic closure semantics,
- statistical mechanics / thermodynamic free energy,
- PAC-Bayesian learning theory,
- and post-quantum / certified robustness interpretations of spectral leakage.

This is not just a bound: it formalizes the idea that self-reflective proof systems admit a finite-temperature control law, and that the same KL complexity that limits generalization in ML also limits uniform self-encoding in reflective logic. That bridge is the breakthrough.

### 11. Required future-facing closing artifact inside the repository

Also create a structured `FUTURE_DIRECTIONS.md` alongside the Lean file containing 3–5 concrete next steps, each at breakthrough scale. Include items such as:
1. a noncommutative / operator-algebraic `quantum` extension with matrix-valued Gibbs states,
2. a `post_quantum` lattice coding interpretation of `klDiv` as spectral leakage,
3. a `certified robustness` theorem for neural closure models via Lipschitz free-energy control,
4. a Sanov large-deviation strengthening replacing the coarse calibration term by an exponential rate function,
5. a tropical or min-plus analogue of prime-spectral reflection capacity.

The Lean development should make those directions look inevitable.

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
            Prove a quantitative bridge between the EML invariants recently introduced for self-reference (thermodynamic reflection capacity and diagonal capacity) and the Gibbs-posterior generalization machinery already established on prime spectra. The core target is a theorem showing that, for a closure self-model endowed with a Gibbs posterior over admissible evaluations/spectral points, high-probability PAC-Bayesian control of empirical self-prediction error implies an explicit upper bound on reflection capacity, with a converse lower-bound regime yielding a learnability/incompleteness phase transition. This would connect statistical learning theory, self-reference, and thermodynamic proof semantics in a way not currently present in the catalog, while avoiding the in-flight minimizer-extraction line.

            ### Precise Mathematical Framing
            Let a closure self-model carry a family of self-evaluation observables measuring reflection/diagonal success on sentences or codes. Define empirical reflection loss on sampled self-tests and a Gibbs posterior proportional to exp(-beta * empirical_loss) relative to a reference prior on SpectralPoint S or admissible evaluations. The main result should be a PAC-Bayes inequality of the form: with high probability over sampled self-tests, for every posterior rho, ReflectionCapacity_beta(S) <= EmpiricalReflectionEnergy(rho) + (KL(rho||pi) + log(1/delta))/n, up to an explicit temperature factor and calibration term derived from the free-energy semantics. A second target is a threshold theorem: if the optimal PAC-Bayes bound drops below a structural constant determined by the self-encoding map, then uniform reflection on the sampled class is impossible unless derivability collapses on a corresponding fragment; contrapositively, nontrivial incompleteness forces a positive generalization gap. This creates an algorithmic pipeline: estimate empirical self-reflection loss, optimize the Gibbs posterior, and obtain certified upper bounds on reflection capacity and predicted incompleteness thresholds. The proof strategy should synthesize existing Gibbs countermodel posterior machinery from Bridges with the recent EML reflection-capacity framework, using Donsker-Varadhan variational principles and concentration for bounded self-evaluation observables.

            ### Lean 4 Sketch
theorem pac_bayes_reflection_capacity_bound
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (pi rho : SpectralPoint S -> ℝ)
    (hpi : IsProbability pi) (hrho : IsProbability rho)
    (Lhat : SpectralPoint S -> ℝ)
    (beta : ℝ) (hbeta : 0 < beta)
    (delta : ℝ) (hdelta : 0 < delta ∧ delta < 1)
    (n : ℕ) :
    ProbEvent delta ->
    reflectionCapacity beta <=
      expected rho Lhat +
      (klDiv rho pi + Real.log (1 / delta)) / (beta * n) + calibrationTerm beta := by
  sorry

theorem reflection_capacity_phase_transition
    [CoherentClosureProofSemiring S] [Fintype (SpectralPoint S)]
    (beta : ℝ) (hbeta : 0 < beta) :
    pacBayesCertificate S beta < criticalSelfEncodingConstant S ->
    ¬ uniformReflectionOnFragment S := by
  sorry

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `diagonal_phase_transition_incompleteness_of_quantitative` : theorem diagonal_phase_transition_incompleteness_of_quantitative
     (file: EML/DiagonalPhaseTransition.lean)
  2. `pac_bayes_prime_spectral_bound_of_mgf` : theorem pac_bayes_prime_spectral_bound_of_mgf {S : Type*} {n : ℕ}
     (file: Bridges/PACBayesBound.lean)
  3. `crystal_error_bound` : theorem crystal_error_bound (x : ℝ) : |x - ↑(round x)| ≤ 1 / 2 :=
     (file: MachineLearning/Crystallization.lean)
  4. `information_lower_bound` : theorem information_lower_bound (P b : ℕ) :
     (file: MachineLearning/Neural/CompilationCompression.lean)
  5. `relu_region_upper_bound` : theorem relu_region_upper_bound (L w : ℕ) (hw : 0 < w) :
     (file: MachineLearning/Neural/LLMSingleMatMul.lean)

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



Recent successful concepts: Thermodynamic Reflection Capacity and a Sharp Incompleteness Threshold for Closure Self-Models, Prime-Spectral Schrödinger Bridge for Closure-Generated Proof Semirings via Entropic Countermodel Transport, Thermodynamic Sanov–Large-Deviation Completeness for Closure Self-Models via Prime-Spectral Free-Energy Rate Function


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

Research domain: MachineLearning
Research mode: prove
