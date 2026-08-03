# Folding the Sphere onto a Plane: A Geometric Lens for Neural Patterns

## The map behind the picture

The human cortex is a folded sheet. At the scale of populations rather than individual neurons, its activity is often described by a **neural field**: a function assigning an average voltage, firing rate, or other activity level to every point of a surface. Such fields can form waves, spots, stripes, and more elaborate motifs. These patterns matter in models of sensory maps, seizures, sleep rhythms, and geometric visual hallucinations.

A recurring mathematical tension lies beneath these models. The global geometry is naturally curved, while almost every screen, plot, and numerical grid is flat. A sphere is the simplest closed curved surface on which to understand that tension. It is not a literal model of every cortical fold, but it captures two essential facts: there is no boundary, and distant directions eventually meet.

Stereographic projection offers a remarkably exact bridge. Imagine placing a sphere above an infinite plane and drawing a ray from the sphere’s north pole through each point of the sphere. Where the ray meets the plane gives the projected point. Reversing this construction wraps the entire plane around the sphere, missing only the north pole. Infinity in every planar direction becomes that single omitted point.

For a planar point $p=(x,y)$, set

$$
D(x,y)=1+x^2+y^2.
$$

The inverse stereographic map is

$$
\sigma(x,y)=\left(\frac{2x}{D(x,y)},\frac{2y}{D(x,y)},
\frac{x^2+y^2-1}{D(x,y)}\right).
$$

These three components will be denoted $X$, $Y$, and $Z$. This compact formula contains the basic geometry needed to transport spherical patterns to a plane.

## Why the formula is safe

The denominator $D(x,y)$ is always positive because $x^2$ and $y^2$ are nonnegative. Thus the map has no finite singularity. Direct algebra gives

$$
X^2+Y^2+Z^2=1,
$$

so every planar point lands exactly on the unit sphere. Conversely, the third coordinate satisfies the complementary identity

$$
1-Z=\frac{2}{1+x^2+y^2}>0.
$$

Every finite planar point therefore lies strictly below the north pole. As $x^2+y^2$ grows, the gap to the pole shrinks. This is how a noncompact plane closes into a compact sphere: all routes to planar infinity converge to one spherical location.

The sphere identity immediately yields a useful bound. Since each square is nonnegative and their sum is one,

$$
|X|\le 1,\qquad |Y|\le 1,\qquad |Z|\le 1.
$$

The simplest spherical patterns—the three coordinate functions—therefore remain uniformly bounded when drawn on the plane. They are the degree-one spherical harmonics, the analogues on a sphere of the simplest sinusoidal modes on a line.

## Infinity remembers the north pole

A subtle point appears when one asks whether a projected spherical pattern “decays at infinity.” Consider the positive horizontal ray $(R,0)$. The first coordinate becomes

$$
X(R,0)=\frac{2R}{1+R^2}.
$$

For $R\ge 1$, it obeys the quantitative estimate

$$
|X(R,0)|\le \frac{2}{R}.
$$

Thus this mode fades to zero. The same behavior holds for $Y$ in corresponding directions. It is tempting to infer that every spherical harmonic must fade on the plane. But the third coordinate tells a different story:

$$
Z(R,0)=\frac{R^2-1}{R^2+1},
\qquad
|1-Z(R,0)|=\frac{2}{1+R^2}.
$$

It approaches $1$, not $0$. This is not a defect of the map. It is a precise statement that planar infinity records the value of the spherical function at the projection pole. A spherical pattern decays to zero after projection only if its north-pole value is zero. More generally, one should subtract the pole value first. The corrected field then has a genuine chance to decay.

This distinction has practical meaning. A simulation on a large planar box may impose zero boundary conditions because the edge is intended to approximate infinity. That choice is geometrically faithful only for fields vanishing at the omitted pole, or for pole-subtracted fields. Otherwise it silently changes the global mode.

## Curvature becomes a weight

Neural-field models often include spatial smoothing or diffusion. On a curved surface the relevant differential operator is the Laplace–Beltrami operator, written $\Delta_{S^2}$ on the sphere. A schematic local neural-field equation is

$$
\Delta_{S^2}u=f(u),
$$

where $u$ is activity and $f$ describes local response. Stereographic coordinates preserve angles but stretch lengths. In two dimensions this conformal stretching turns curvature into a spatial weight. With a fixed sign convention, the expected transformation is

$$
(\Delta_{S^2}u)\circ\sigma
=\frac{(1+x^2+y^2)^2}{4}\,\Delta(u\circ\sigma).
$$

The flat picture is therefore not governed by an ordinary translation-invariant equation: its coefficients remember the sphere. Near the origin the distortion is modest; far away the conformal factor grows rapidly. This is the mathematical price—and benefit—of placing a closed geometry on an infinite plane.

The exact geometric identities above establish the coordinate foundation for that transformation. A complete neural-field theory must additionally specify whether interactions are local or integral, the response law, and the connectivity kernel.

## Counting modes without overcounting patterns

Spherical harmonics are organized by a nonnegative integer degree $k$. The space of degree-$k$ harmonics on the two-sphere has dimension

$$
2k+1.
$$

One way to see the number is to start from homogeneous polynomials in three variables. There are

$$
\binom{k+2}{2}
$$

monomials of total degree $k$. Those divisible by the radial quadratic form contribute a subspace with dimension

$$
\binom{k}{2}.
$$

Removing this trace part leaves the harmonic polynomials, and

$$
\binom{k+2}{2}-\binom{k}{2}=2k+1.
$$

If a neural interaction operator selects exactly degree $k$, its selected eigenspace therefore has dimension $2k+1$. Under the proposed reciprocal relation $r=1/k$ between an interaction radius $r$ and selected degree, the first three cases are:

- $r=1$, corresponding to $k=1$: dimension $3$;
- $r=1/2$, corresponding to $k=2$: dimension $5$;
- $r=1/3$, corresponding to $k=3$: dimension $7$.

These are exact mode counts. They are not, by themselves, counts of stable nonlinear patterns. A vector space of dimension $2k+1$ contains infinitely many functions. Rotations mix these functions continuously, and nonlinear dynamics may select isolated branches, continuous families, or no stable branch at all.

That warning sharpens rather than weakens the theory. Representation theory tells us the size and symmetry of the linear stage on which pattern formation occurs. Stability requires a second act: a specified kernel, activation function, bifurcation parameter, and equivalence rule for patterns related by rotation.

## The Mexican-hat question

A frequently used neural interaction profile is “Mexican-hat” connectivity: nearby populations excite one another, while a surrounding annulus inhibits them. Such competition can prefer a characteristic wavelength. On the sphere, a rotationally symmetric kernel acts diagonally on spherical-harmonic degrees, so its spectral coefficients determine which degree destabilizes first.

The attractive conjectural picture is that an interaction radius $r=1/k$ selects degree $k$, giving a $2k+1$-dimensional critical eigenspace. The geometry and multiplicity are exact once that spectral-selection hypothesis is made. But the selection rule itself depends on the precise shape and normalization of the kernel; “Mexican hat” describes a family, not a unique operator. Establishing it requires calculating the kernel’s Fourier–Legendre coefficients.

Even after a degree becomes critical, exact stable-solution counting requires nonlinear analysis. One must distinguish basis modes from arbitrary linear combinations, and distinguish genuinely different patterns from rotations of the same pattern. These questions lead naturally to equivariant bifurcation theory, where the rotation group $SO(3)$ organizes the possible branches.

## What the flat patterns can teach us

There is also a useful way to read the map dynamically. A point moving outward along a straight planar ray does not wander forever over the sphere. It starts near the south pole, crosses the equator when its planar radius is $1$, and then climbs toward the north pole. The journey slows in spherical coordinates even while the planar radius keeps increasing. A ring drawn far from the planar origin therefore represents a narrow spherical neighborhood near the missing pole. Equal distances on the page do not represent equal distances on the sphere.

That compression changes how one should interpret images. A broad outer band in a planar plot may correspond to a tiny cap of cortex in the spherical model. Conversely, a smooth pattern near the north pole can appear spread across a huge area near the boundary of a truncated plot. Color maps and numerical meshes should therefore be read with the conformal scale in mind. Adaptive grids, or direct spherical discretizations used alongside planar visualization, can help prevent the picture from dictating the physics.

The stereographic view offers a useful conceptual laboratory. It converts global spherical modes into explicit rational functions on the plane. It shows that boundedness survives projection, while decay depends on a pole condition. It turns harmonic multiplicity into concrete counts—three, five, seven for the first reciprocal radii—without pretending that dimension equals the number of stable states.

For visual neuroscience, these distinctions matter. Planar images of spots or stripes may look like ordinary Euclidean patterns, yet their stretching and behavior near the boundary can encode a hidden closed surface. A pattern that tends to a constant at the edge is not necessarily a numerical artifact; it may be the value at the missing pole. A family with five coefficients is not necessarily five percepts; it is a five-dimensional space on which rotations and nonlinearities still act.

The next steps are clear. Build explicit bases for degrees one through three. Prove a general theorem that subtracting the pole value produces decay, with rates determined by smoothness. Derive the conformally weighted Laplacian in full. Then choose a concrete difference-of-Gaussians kernel, compute its spherical spectrum, and analyze the nonlinear bifurcations.

The broader lesson is geometric. Flattening a curved world never erases curvature; it relocates it—into weights, asymptotics, and boundary behavior. Once those traces are read correctly, the infinite plane becomes a faithful window onto activity unfolding over a closed neural surface.