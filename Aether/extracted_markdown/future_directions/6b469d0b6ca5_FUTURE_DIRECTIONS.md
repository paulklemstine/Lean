# Future Directions: Formal Class Field Theory

## Hypothesis 1: Artin Map Prototype for Cyclotomic Extensions

**Conjecture:** For the cyclotomic extension Q(ζ_n)/Q, one can define a formal Artin map from ideals coprime to (n) to the Galois group Gal(Q(ζ_n)/Q) ≅ (Z/nZ)× by sending the ideal (p) (for p ∤ n) to the Frobenius element σ_p : ζ_n ↦ ζ_n^p. This map is multiplicative and descends to a ray class quotient.

**Test:** Construct the map `artinMap : {I : Ideal (𝓞 Q) // I.IsCoprime (Ideal.span {n})} → (ZMod n)ˣ` and prove:
1. `artinMap ((p)) = (p : (ZMod n)ˣ)` for primes p ∤ n.
2. `artinMap (I * J) = artinMap I * artinMap J`.
3. `artinMap ((a)) = (a : (ZMod n)ˣ)` for a ≡ 1 mod n (triviality on congruence subgroup).

**Success criterion:** All three properties proved sorry-free using Mathlib's `CyclotomicField` and `IsPrimitiveRoot` infrastructure.

**Failure criterion:** If `CyclotomicField` lacks the Frobenius endomorphism or the connection between `ZMod n` units and `Gal(Q(ζ_n)/Q)` is not formalized, this identifies the precise missing API.

**Impact:** This would be the first formally verified Artin map, the core of explicit class field theory. It would validate the ray class group architecture by showing it produces the correct Galois-theoretic output.

---

## Hypothesis 2: Transfer-Corestriction Comparison in Degree 0

**Conjecture:** The formal transfer `GroupTransfer.transferHom G U : G →* Abelianization U` coincides with degree-0 corestriction `cor: H^0(U, Z) → H^0(G, Z)` (or rather its dual), where `H^0(G, Z)` is identified with coinvariants/abelianization.

More precisely: there exists a commutative diagram

```
G ---Ver--→ U^ab
|               |
↓ proj          ↓ ≅
G^ab ←-cor-- U^ab
```

connecting the transfer to the standard group cohomology corestriction.

**Test:** Define `cor₀ : Abelianization U →* Abelianization G` as the map induced by inclusion `U → G`, and prove:
```lean
theorem transfer_cor_commute :
    Abelianization.lift (Abelianization.of.comp U.subtype) ∘ 
    (Abelianization.equivOfComm).symm ∘ GroupTransfer.transferFun U =
    Abelianization.of.comp (·^[G:U])
```
(adapted to actual Lean syntax).

**Success criterion:** The diagram commutes for all finite groups G with abelian U, proved sorry-free.

**Failure criterion:** If `Abelianization.lift` cannot express the relevant composition, this isolates the missing functoriality lemma in `Abelianization`.

**Impact:** Would connect our transfer formalization to Mathlib's emerging group cohomology infrastructure, opening the path to `H^1` transfer and Tate cohomology.

---

## Hypothesis 3: Ray Class Cardinality Engine for Quadratic Fields

**Conjecture:** From the exact sequence
```
1 → (O_K/m)× / im(O_K×) → Cl_m(K) → Cl(K) → 1
```
one can derive a computable cardinality formula for ray class groups of imaginary quadratic fields Q(√d) with squarefree d < 0 and modulus m = (p) for an odd prime p that is inert in K.

The formula should be:
```
|Cl_m(K)| = h_K · (p² - 1) / w_K
```
where h_K is the class number and w_K = |O_K×|.

**Test:** Instantiate for:
- Q(√-5), m = (3): predict |Cl_{(3)}| = 2 · 8 / 2 = 8
- Q(√-5), m = (7): predict |Cl_{(7)}| = 2 · 48 / 2 = 48
- Q(√-1), m = (3): predict |Cl_{(3)}| = 1 · 8 / 4 = 2

Verify computationally against known tables (e.g., LMFDB).

**Success criterion:** The formula matches LMFDB data for at least 5 test cases, and the Lean formalization of the exact sequence cardinality consequence compiles.

**Failure criterion:** The formula fails for ramified primes or split primes, identifying the precise modification needed (e.g., different local unit group structure).

**Impact:** Would create a certified ray class group enumeration engine, enabling systematic formal verification of conductor calculations for abelian extensions.

---

## Hypothesis 4: Capitulation Criterion for Cyclic Extensions

**Conjecture:** For a cyclic extension L/K of prime degree p with Galois group G = Z/pZ acting on Cl(L), the capitulation kernel ker(j: Cl(K) → Cl(L)) satisfies:

```
|ker(j)| = |Cl(K)[p]| · |H^1(G, O_L×)| / |H^0_T(G, Cl(L))|
```

where Cl(K)[p] is the p-torsion and H^0_T is the Tate cohomology.

In the abstract group-theoretic setting, this reduces to: for a cyclic group G = ⟨σ⟩ of order p acting on a finite abelian group A, the map N: A → A^G (norm) has:

```
|ker(N)| / |A^G / N(A)| = 1   (Herbrand quotient = 1 for finite modules)
```

**Test:** Prove the Herbrand quotient equals 1 for a finite Z[G]-module with G cyclic:
```lean
theorem herbrand_quotient_one (G : Type*) [Group G] [IsCyclic G] [Fintype G]
    (A : Type*) [CommGroup A] [Fintype A] [MulAction G A] :
    Fintype.card (fixedPoints G A) * Fintype.card (kerNorm G A) = 
    Fintype.card (imageNorm G A) * Fintype.card (H1_hat G A)
```

**Success criterion:** The Herbrand quotient identity proved for cyclic G acting on finite A, sorry-free.

**Failure criterion:** If Mathlib lacks `fixedPoints`, `MulAction.ker`, or the norm map for group actions, this identifies the exact missing components.

**Impact:** The Herbrand quotient is the key tool for computing capitulation and class number relations in cyclic extensions. Its formalization would be a major step toward the Chevalley-Herbrand formula.

---

## Hypothesis 5: Conductor Sensitivity — Distinct Moduli Yield Distinct Ray Class Groups

**Conjecture:** For K = Q(√-5), the ray class groups modulo (2) and modulo (4) are non-isomorphic as abstract groups.

Specifically:
- Cl_{(2)}(K) ≅ Z/2Z × Z/2Z (Klein four-group, order 4)
- Cl_{(4)}(K) has order 8 and is NOT isomorphic to (Z/2Z)³

This demonstrates that the ray class group is genuinely sensitive to the exponent of the modulus, not just its support.

**Test:**
1. Compute |Cl_{(4)}(K)| using the exact sequence with m = (4):
   - (O_K/(4))× has order φ(N(4)) adjusted for the ring structure
   - The image of O_K× in (O_K/(4))× determines the kernel
2. Determine the group structure (cyclic factors)
3. Prove `¬ (Cl_{(2)}(K) ≅ Cl_{(4)}(K))` formally

**Success criterion:** The computation |Cl_{(4)}| ≠ |Cl_{(2)}| verified computationally (establishing non-isomorphism by cardinality alone), with the exact sequence framework giving the structural reason.

**Failure criterion:** If |Cl_{(4)}| = |Cl_{(2)}| (meaning exponent doesn't change cardinality in this case), then conductor sensitivity must be demonstrated via group structure rather than cardinality, requiring a finer invariant.

**Impact:** Demonstrates that the ray class group formalism is genuinely non-trivial: different moduli with the same support produce different answers. This is the first test of "conductor-sensitive arithmetic" in a formal setting.

---

## Priority Ordering

1. **Hypothesis 3** (Ray class cardinality engine) — most immediately testable, builds directly on current work, has computational verification path.
2. **Hypothesis 1** (Artin map prototype) — highest mathematical impact, but depends on Mathlib's cyclotomic infrastructure.
3. **Hypothesis 5** (Conductor sensitivity) — concrete and falsifiable, good validation of the exact sequence framework.
4. **Hypothesis 4** (Capitulation criterion / Herbrand quotient) — fundamental but requires group action cohomology infrastructure.
5. **Hypothesis 2** (Transfer-corestriction comparison) — conceptually important but depends on group cohomology API not yet in Mathlib.

Each hypothesis is designed to be independently testable within a single research cycle, with clear success/failure criteria that produce useful information regardless of outcome.
