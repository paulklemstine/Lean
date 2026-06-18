# Future Directions for Tropical Spectrum Duality

## Formalized Results

This file establishes the tropical evaluation spectrum duality: for a compact Hausdorff
space X and an algebra of continuous functions that kernel-separates points, the natural
evaluation-to-spectrum map is a homeomorphism. This has been fully formalized in Lean 4
with complete proofs.

## Next Theorems to Formalize

### 1. Functoriality of the Tropical Spectrum

Every continuous map `f : X → Y` between compact Hausdorff spaces induces a
pullback map `f* : A_Y → A_X` on function algebras, which in turn induces a
continuous map on tropical spectra. This should give a contravariant functor
from CompHaus to the category of tropical spectral spaces.

```
theorem tropSpec_functorial (f : C(X, Y)) :
    Continuous (tropSpecMap f) ∧ tropSpecMap (ContinuousMap.id X) = id
```

### 2. Spectral Compactness

The tropical evaluation spectrum of a compact space is compact.
This follows immediately from the homeomorphism theorem but could also
be proved directly from the definition, which would give an independent
proof of compactness of the congruence space.

```
theorem tropEvalSpec_compact [CompactSpace X] :
    @CompactSpace (TropEvalSpec A eval) (tropEvalSpecTopology A eval)
```

### 3. Spectral Semisimplicity

The intersection of all evaluation congruences is the diagonal (equality):
```
theorem tropSpec_semisimple
    (hsep : ∀ x y : X, x ≠ y → ∃ f, eval x f ≠ eval y f) :
    ⨅ x, evalCongr A eval x = ⊥
```
This formalizes the fact that the algebra detects all function-level distinctions.

### 4. Tropical Structure Sheaf

Define a structure presheaf on the tropical spectrum by assigning to each
open set the algebra of "tropical regular functions" — sections of the
natural projection from the function algebra. Prove it satisfies the sheaf
condition.

```
def tropStructureSheaf : TopCat.Presheaf (Type*) (tropSpecTop A eval)
theorem tropStructureSheaf_isSheaf : tropStructureSheaf.IsSheaf
```

### 5. Tropical Stone–Weierstrass on the Spectrum

Show that the density results from tropical Stone–Weierstrass translate
to a statement about the spectrum: every closed set in the spectrum is
an intersection of tropical vanishing loci. This connects approximation
theory to spectral geometry.

```
theorem tropVanishPair_generates_closed :
    ∀ s : Set (TropEvalSpec A eval),
      @IsClosed _ (tropEvalSpecTopology A eval) s ↔
        ∃ I : Set (A × A), s = ⋂ p ∈ I, tropVanishPair A eval p.1 p.2
```

## Connections to Other Work

- **Maslov dequantization**: The tropical spectrum should be the ℏ → 0 limit
  of the classical Gelfand spectrum, connecting to the Maslov dequantization
  framework already partially formalized in the catalog.

- **Tropical Langlands**: The spectral functor should extend to the
  tropical Satake setting, giving a geometric interpretation of the
  tropical Satake isomorphism for reductive groups.

- **Neural network interpretability**: Evaluation congruences on ReLU/max-plus
  networks correspond to activation regions, suggesting spectral methods
  for understanding neural network decision boundaries.
