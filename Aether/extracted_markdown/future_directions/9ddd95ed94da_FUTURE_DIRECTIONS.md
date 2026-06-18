# Future Directions — The Fundamental Theorem of Identity Systems and Homotopy-Initial Families

## Synthesis of this cycle

The catalog's synthetic-HoTT layer (`Catalog/Logic/HoTT/Foundations.lean`) introduced
data-carrying `Contractible`, a bespoke `Equiv'` with full computational content, and the
`IdentitySystem` structure — an `A`-indexed family `R` equipped with a reflexivity witness
and a *correctly-centred contractible total space* `Σ' a, R a`. Crucially, the file *stated*
in its docstring that "the fundamental theorem says this data yields an equivalence
`(a₀ = a) ≃' R a`", but it never proved it. That promissory note was the conceptual hole in
the layer.

This cycle closes it. `Catalog/Logic/HoTT/IdentitySystems.lean` proves the
**Fundamental Theorem of Identity Systems** (`fundamentalIdentitySystem`): for any
`IdentitySystem A a₀ R` and any `a : A`, encode/decode are mutually inverse, so
`(a₀ = a) ≃' R a`. The forward map is path transport of the reflexivity witness; the inverse
is recovered from contractibility of the total space. We then harvest three structural
corollaries:

- `Equiv'.contractible` — contractibility is an invariant of `≃'` (a missing piece of the
  catalog's `Equiv'` API);
- `idSys_base_fiber_contractible` — in any identity system the base fibre `R a₀` is
  contractible;
- `idSys_unique` — **homotopy-initiality**: any two identity systems based at the same point
  are *fibrewise equivalent*, so the based path family is unique up to equivalence.

All results are `sorry`-free and depend only on `propext`.

## Results summary

| Theorem | Statement | Status |
|---|---|---|
| `fundamentalIdentitySystem` | `IdentitySystem A a₀ R → (a₀ = a) ≃' R a` | ✅ proved |
| `Equiv'.contractible` | `α ≃' β → Contractible α → Contractible β` | ✅ proved |
| `idSys_base_fiber_contractible` | `IdentitySystem A a₀ R → Contractible (R a₀)` | ✅ proved |
| `idSys_unique` | two identity systems at `a₀` ⇒ `R a ≃' R' a` | ✅ proved |
| `fundamental_path_encode_rfl` | encode of the path family sends `rfl ↦ rfl` | ✅ proved |

The decisive structural fact exploited throughout: in Lean 4 `Eq` is `Prop`-valued, so the
path side of every equivalence is automatically a subsingleton (UIP). This made one triangle
of the fundamental equivalence free and concentrated all homotopical content into transporting
a fibre witness back along a recovered base path.

## Research directions

### 1. The converse: contractible total space *characterizes* identity systems

We proved that an identity system yields a fibrewise equivalence to the path family. The
sharper, fully bidirectional statement is the genuine fundamental theorem: a family `R` with
`r₀ : R a₀` is an identity system **iff** the canonical map `(a₀ = a) → R a` is an equivalence
for every `a`, **iff** the total space `Σ' a, R a` is contractible. We have one of the three
implications; the conjecture is that the remaining two are provable inside the catalog's
data-carrying `Contractible`/`Equiv'` setting with no new axioms. Concretely: from
`(∀ a, IsEquiv (encode))` build `Contractible (Σ' a, R a)` with center `⟨a₀, r₀⟩`.
*The key insight is* that contractibility of `Σ' a, R a` is equivalent to the "based map out"
being unique, which the per-fibre equivalences assemble into directly via the singleton
contractibility of `Σ' a, (a₀ = a)`. **Why now?** With `fundamentalIdentitySystem` and
`Equiv'.contractible` in place, the converse is a short assembly: transport contractibility of
the path total space across the fibrewise equivalence — exactly the lemma we just added.

### 2. Transport / structure identity principle for the catalog's structures

`idSys_unique` says identity systems are determined up to equivalence by their base point.
The natural escalation is a **structure identity principle**: equivalent structures
(e.g. two `Contractible` witnesses, two `Equiv'`s between the same types) are themselves equal
in the appropriate sense. Conjecture: for the catalog's `HProp'` universe, `HPropEquiv P Q`
implies `P = Q` *given propositional univalence*, and unconditionally implies they are
`Equiv'`-equivalent as types. *The key insight is* that `HProp'` is a subsingleton-valued
universe, so logical equivalence already upgrades to type equivalence without univalence — the
univalent step is only needed to turn that equivalence into an honest `Eq`. **Why now?** The
`Equiv'.contractible` invariance lemma is the engine that turns "logically equivalent" into
"equivalent as contractible-up-to data", making the unconditional half immediate.

### 3. Closure properties of identity systems (products, pullbacks, Σ)

Identity systems should be closed under the operations that the path family is closed under.
Conjecture: if `R` is an identity system on `A` at `a₀` and `R'` one on `A'` at `a₀'`, then
`fun (p : A × A') => R p.1 × R' p.2` is an identity system on `A × A'` at `(a₀, a₀')`; likewise
identity systems pull back along any `f : B → A`. *The key insight is* that contractibility of
a product/dependent-sum of total spaces reduces, via `Equiv'.contractible` and the
`Σ`-distribution equivalence, to contractibility of the factors. **Why now?** We can now state
these as `Equiv'` chains between total spaces and discharge them with the contractibility
transport lemma rather than re-deriving path induction each time.

### 4. A `J`-eliminator / induction principle generated by any identity system

Path induction (`Eq.rec`) is the eliminator for the *based path* identity system. Conjecture:
every `IdentitySystem A a₀ R` induces a bespoke dependent eliminator
`(D : ∀ a, R a → Sort w) → D a₀ rflR → ∀ a r, D a r`, definable purely from
`fundamentalIdentitySystem` plus `Eq.rec`, and satisfying the expected computation rule
`elim D d a₀ rflR = d` (up to the proof-irrelevance of the base path). *The key insight is*
that transporting along `decode r : a₀ = a` converts a fibre `r : R a` into the base case,
which is exactly the recursor for `R` once the fundamental equivalence identifies `R a` with
the path space. **Why now?** `idSysDecode` already extracts the base path and
`fundamentalIdentitySystem`'s `right_inv` guarantees the round-trip, so the computation rule is
within reach of the same `subst`-based argument used here.

### 5. Connecting `IdentitySystem` to Mathlib's `Equiv` and `IsEquiv` ecosystem

The catalog deliberately keeps `Equiv'` independent of Mathlib's `Equiv`. A bridging direction:
build a forgetful map `Equiv' α β → (α ≃ β)` for `α β : Type` and show it is an equivalence of
equivalences, then re-express `fundamentalIdentitySystem` as a Mathlib `Equiv`
`(a₀ = a) ≃ R a`. Conjecture: this bridge makes every catalog identity-system result importable
into mainstream Mathlib developments (e.g. transport, `Equiv.subsingleton`) for free.
*The key insight is* that the two roundtrip laws of `Equiv'` are exactly `left_inv`/`right_inv`
of Mathlib's `Equiv`, so the bridge is a definitional repackaging on `Type` and an honest lemma
on the contractibility predicates. **Why now?** With the fundamental equivalence proved
internally and shown to use only `propext`, exporting it to Mathlib's API unlocks cross-domain
reuse (topology, category theory) at essentially zero marginal proof cost.
