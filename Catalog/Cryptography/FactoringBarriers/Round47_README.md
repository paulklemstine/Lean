# Round 47 — index

**44 notes, 4 Lean files, 67 commits, one issue: [#515](https://github.com/paulklemstine/Lean/issues/515).**

**START HERE: [`Round47_SUMMARY.md`](Round47_SUMMARY.md).** It is current as of the final
close and supersedes the intermediate notes on two points (the "half the moduli are dead"
claim, and the 336-bit crossover). The numbered notes below are in the order they were
*believed*; several are wrong in ways their banners record.

## The five things worth reading

| file | what it is |
|---|---|
| `Round47_SUMMARY.md` | the entry point, current |
| `Round47_DimensionalClosure.lean` | the structural core: `h(α) = g²` costs `d−2` dimensions → a curve for every `d` |
| `Round47_Method.md` | the algorithm, and the claims that later audits narrowed |
| `Round47_Audit.md` | the independent audit that **broke** the original headline |
| `Round47_Final.md` | the close: everything costed, one question left |

## The rest, in order

- `Round47_EllipticReduction.md`, `Round47_GeneralCubic.md` — the reduction, and its
  extension to the full cubic `f = X³+PX+Q`
- `Round47_MordellWeil.md` — the `ellrank`-based version (void: the descent factors `N`)
- `Round47_Circularity.md` — `N² ∣ disc(E)`, and why the 12/12 was vacuous
- `Round47_DegreeBarrier.md` — genus 1 → 5 → 17 → 49
- `Round47_PhantomSources.md` — the handover's "only live direction" rests on a citation that
  does not exist
- `Round47_StandardPipeline.md` — the standard NFS pipeline runs; the loop does not close
- `Round47_HMBarrier.md` — the auxiliary-information barrier, **derived**
- `Round47_GNFSConstant.md`, `Round47_ConstantCusp.md` — the constant is pinned by a cusp
- `Round47_LatticeAndLimit.md` — the lattice step is `poly(log N)`; supply kills it
- `Round47_ExponentQuarter.md` — the supply exponent is `−1/4`, **not** `−1/6`
- `Round47_SelectorClosed.md` — the last open question, closed negatively
- `Round47_Retractions4.md`, `Round47_MultiplicativityCorrection.md` — my own errors

## The rules this round earned

1. **A run that reads as a negative is a suspect instrument first.**
2. **A run that reads as an absence is a suspect *sample* first.**
3. **A control that reports success over zero instances is worse than no control**, because
   it is green.
4. **Render the page.** `pdftotext` changed a conclusion three times in one day — once by
   dropping a cube root *and* a square root in the same display.
5. **Before believing a negative, check that the thing you varied actually varied.** I
   believed a boundary in the *moduli*; it was a constant in the *selector*.
6. **A null result with a mechanism behind it is worth more than a positive result without
   one.**
