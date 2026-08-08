import Probability.ThreeCubes.Basic
import Probability.ThreeCubes.LocalSolvability
import Probability.ThreeCubes.Padic
import Probability.ThreeCubes.Moduli
import Probability.ThreeCubes.Geometry
import Probability.ThreeCubes.Counting
import Probability.ThreeCubes.Density
import Probability.ThreeCubes.Witnesses
import Probability.ThreeCubes.Rational
import Probability.ThreeCubes.RationalWitnessesA
import Probability.ThreeCubes.RationalWitnessesB
import Probability.ThreeCubes.RationalWindow
import Probability.ThreeCubes.LowerBounds
import Probability.ThreeCubes.LowerBoundsSharp
import Probability.ThreeCubes.FourCubes
import Probability.ThreeCubes.FourCubesExtended

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