import Probability.Basic
import Probability.LocalSolvability
import Probability.Padic
import Probability.Moduli
import Probability.Geometry
import Probability.Counting
import Probability.Density
import Probability.Witnesses
import Probability.Rational
-- The certified rational-witness banks `RationalWitnessesA` / `RationalWitnessesB`
-- (1001 witnesses for `0 ≤ n ≤ 1000`) are not present in this catalog snapshot,
-- and `Probability.RationalWindow` depends on them, so the three imports below
-- cannot be resolved and are commented out.  Everything else in the development
-- is imported and builds.
-- import Probability.RationalWitnessesA
-- import Probability.RationalWitnessesB
-- import Probability.RationalWindow
import Probability.LowerBounds
import Probability.LowerBoundsSharp
import Probability.FourCubes
import Probability.FourCubesExtended

/-!
# Sums of three cubes — index module

This module gathers the whole development on the affine cubic surface
`x³ + y³ + z³ = n`:

| file | content |
| --- | --- |
| `Basic` | definitions, the mod `9` obstruction, closure properties, Mahler's families |
| `LocalSolvability` | `LocallySolvable n ↔ n ≢ ±4 (mod 9)` |
| `Padic` | `ℤ_p`-points for all `p` `↔ n ≢ ±4 (mod 9)` |
| `Moduli` | `9` is the unique obstructing modulus; every integer is a sum of five cubes |
| `Geometry` | projective points; lines on the surface `↔` `n` is a cube (via FLT₃) |
| `Counting` | `≫ B^{1/4}` and `≫ B^{1/3}` representations of `1` and `2` |
| `Density` | the locally solvable integers have density exactly `7/9` |
| `Witnesses` | the Hasse principle verified for all `|n| ≤ 113`, with large witnesses |
| `Rational` | over `ℚ` the mod `9` obstruction disappears: every `|n| ≤ 113` is a sum of three rational cubes, and infinitely many integers are rationally but not integrally representable |
| `RationalWitnessesA/B` | `1001` certified rational witnesses, `0 ≤ n ≤ 1000`, all with denominator `≤ 12` |
| `RationalWindow` | every `|n| ≤ 1000` is a sum of three rational cubes, including the nine integrally open cases below `1000` |
| `LowerBounds` | the unconditional power-saving lower bound `repCount N ≫ N^{5/9}`, and every rational is a sum of four rational cubes |
| `LowerBoundsSharp` | the sharper lower bound `repCount N ≫ N^{19/27}`, by nesting the cube-gap trick over all three cubes |
| `FourCubes` | linear families of four cubes: every `n ≢ ±4 (mod 9)`, `n ≢ ±2, ±16 (mod 54)` is a sum of four cubes; no congruence obstruction for four cubes |
| `FourCubesExtended` | six further families reduce the uncovered set to `n ≡ ±38, ±52, ±70 (mod 216)`: `162` of the `168` admissible classes mod `216` |
-/