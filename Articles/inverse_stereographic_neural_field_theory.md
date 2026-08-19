# The Geometry of Seeing Things That Aren't There

## How a single algebraic trick turns the folded sphere of the cortex into a flat sheet — and predicts exactly how many hallucination patterns a brain can have

### Ghosts in the visual system

Close your eyes and press gently on your eyelids. Stare at a flickering light. Take one of a long list of psychoactive compounds, or simply fall into the borderland between waking and sleep. In all of these situations, most people see the same handful of things: rotating spirals, honeycomb lattices, concentric rings, radiating fans, chequerboard tunnels.

These are the *form constants*, catalogued in the 1920s and rediscovered in every decade since. Their most remarkable feature is not that they occur, but that they are so *few*. Billions of neurons, an essentially unbounded space of possible activity patterns — and the brain, left to its own devices, produces a short and stable menu.

The dominant mathematical explanation is that these patterns are not pictures of anything. They are the *eigenmodes of the cortex itself*: the shapes that spontaneously grow when a sheet of excitable tissue with short-range excitation and longer-range inhibition becomes unstable. The tissue is doing what a drumhead does when you strike it — vibrating in the few shapes its geometry allows. What you "see" is the shape of your own cortex ringing.

This article is about making that story quantitative, and about a piece of nineteenth-century geometry that makes it tractable: **stereographic projection**.

### Neural fields, in one paragraph

A *neural field* replaces the discrete tangle of neurons with a continuous activity function $u$ on a cortical domain. Its evolution is governed by an equation of the form

$$\partial_t u(p,t) = -u(p,t) + \int K(p,q)\, S\big(u(q,t)\big)\, dq,$$

where $S$ is a sigmoidal firing rate and $K$ is a *connectivity kernel*. The classical choice for $K$ is the **Mexican hat**: positive (excitatory) at short range, negative (inhibitory) at intermediate range, negligible far away, with a characteristic *interaction radius* $r$. Linearise around a uniform resting state and you get a linear operator whose eigenfunctions are the candidate patterns and whose eigenvalues say which ones grow.

If the cortex were an infinite flat plane, the eigenfunctions would be plane waves and the analysis would be a Fourier transform. But the cortical sheet is not an infinite plane. Topologically, each cortical hemisphere — and the closed cortical surface as an idealised whole — is a **sphere**. And on a sphere, "which shapes can ring" has a famously rigid answer.

### The rigidity of the sphere

On the round unit sphere $S^2$ the natural analogue of the Fourier basis is the family of **spherical harmonics**. They are the eigenfunctions of the Laplace–Beltrami operator $\Delta_{S^2}$, the sphere's intrinsic notion of "curvature of a function":

$$\Delta_{S^2} Y = -\,l(l+1)\, Y, \qquad l = 0,1,2,\dots$$

The crucial fact — the source of everything that follows — is that the eigenvalue $-l(l+1)$ does not come with one eigenfunction, but with exactly

$$2l+1$$

independent ones. There is one constant ($l=0$), three dipoles ($l=1$), five quadrupoles ($l=2$), seven octupoles ($l=3$). The reason is representation theory: the rotation group $SO(3)$ acts on the sphere, it must permute the eigenspace of a given eigenvalue among itself, and its irreducible real representations have precisely the dimensions $1, 3, 5, 7, \dots$. The count can also be read off from polynomials: a degree-$l$ harmonic is the restriction of a homogeneous polynomial of degree $l$ in three variables that is annihilated by the flat Laplacian, and

$$\binom{l+2}{2} - \binom{l}{2} = 2l+1.$$

So the sphere hands us a discrete, exactly-counted menu of shapes. If a Mexican-hat kernel picks one degree $l$, the brain gets $2l+1$ patterns and no more. That is the mechanism behind the pattern count — and it is what we will make precise.

### Flattening the sphere without lying about it

Working directly on the sphere is unpleasant: the Laplace–Beltrami operator in spherical coordinates has singularities at the poles, and the natural picture of a "hallucination pattern" is a picture in the *plane* (the visual field, the retina, the flattened cortical map).

**Inverse stereographic projection** solves this. Place the unit sphere so that its north pole sits above the plane, and map each plane point $(x,y)$ to the point where the line to the north pole pierces the sphere:

$$\sigma(x,y) = \big(2xW,\; 2yW,\; (x^2+y^2-1)W\big), \qquad W = W(x,y) = \frac{1}{1+x^2+y^2}.$$

The image really is on the sphere: $\sigma_1^2+\sigma_2^2+\sigma_3^2 = 1$ identically. The origin of the plane goes to the south pole; the unit circle goes to the equator; and as $|(x,y)| \to \infty$ the image climbs to the north pole, which is the single point the chart misses.

What makes this map special is not that it flattens the sphere — many maps do — but *how* it distorts. Pulling the ambient Euclidean metric back through $\sigma$ gives

$$\sigma^*(dX^2+dY^2+dZ^2) = 4W^2\,(dx^2+dy^2).$$

Angles are preserved exactly; only scale changes, by the single positive factor $4W^2$. In two dimensions this has a magical consequence: the Laplace–Beltrami operator of the curved metric is the *flat* Laplacian divided by the conformal factor,

$$\Delta_g = \frac{1}{4W^2}\,\Delta_{\text{flat}}.$$

The eigenvalue equation on the sphere therefore becomes a completely explicit equation on the plane:

> **Transported eigenvalue equation.** A function $u$ on the plane is the stereographic image of a degree-$l$ spherical harmonic exactly when
> $$\Delta_{\text{flat}}\, u = -\,l(l+1)\,\big(4W^2\big)\,u, \qquad W = (1+x^2+y^2)^{-1}.$$

No poles, no coordinate singularities, no special functions: just a flat Laplacian and a weight.

### The algebra that closes on itself

Here is the observation that turns this into a *calculus* rather than a sequence of increasingly grim differentiations.

Every object in sight — the three chart coordinates $\sigma_1 = 2xW$, $\sigma_2 = 2yW$, $\sigma_3 = (x^2+y^2-1)W$, every harmonic pulled back through them, the conformal weight itself — is a **polynomial in the three symbols $x$, $y$, and $W$**. And this algebra is *closed under differentiation*, because

$$\partial_x W = -2xW^2, \qquad \partial_y W = -2yW^2.$$

Differentiating never produces anything new; it produces more polynomials in $x$, $y$, $W$. So one can define differentiation purely as a rewriting rule on symbols, and then prove — once, by induction on the structure of the expression — that this symbolic operation always agrees with the genuine analytic derivative. Every Laplacian in the whole theory is then a finite piece of polynomial algebra.

Two structural identities do all the remaining work. For each chart coordinate $\sigma_i$,

$$\Delta_{\text{flat}}\, \sigma_i = -2\,(4W^2)\,\sigma_i, \qquad \nabla \sigma_i \cdot \nabla \sigma_j = 4W^2\big(\delta_{ij} - \sigma_i \sigma_j\big).$$

The first says each coordinate is a degree-one harmonic ($l(l+1) = 2$). The second is the induced metric of the sphere, written in the flat chart: it encodes the constraint $\sum \sigma_i^2 = 1$ at the level of gradients. Combine them with the Leibniz rule for the Laplacian,

$$\Delta(uv) = u\,\Delta v + v\,\Delta u + 2\,\nabla u \cdot \nabla v,$$

and the eigenvalue relation propagates by pure algebra from the three coordinates to *every* polynomial harmonic. For instance, for two orthogonal coordinates, $\Delta(\sigma_i \sigma_j) = -6\,(4W^2)\,\sigma_i\sigma_j$ — exactly the degree-two eigenvalue $l(l+1)=6$ — and for three, $\Delta(\sigma_1\sigma_2\sigma_3) = -12\,(4W^2)\,\sigma_1\sigma_2\sigma_3$, the degree-three eigenvalue.

Running this machine produces the fifteen patterns of degrees $1$, $2$, $3$ explicitly as functions on the plane: the three dipoles $\sigma_1, \sigma_2, \sigma_3$; the five quadrupoles $\sigma_1\sigma_2$, $\sigma_1\sigma_3$, $\sigma_2\sigma_3$, $\sigma_1^2-\sigma_2^2$, $3\sigma_3^2-1$; and the seven octupoles including the three-fold sectoral pair $\sigma_1(\sigma_1^2-3\sigma_2^2)$ and $\sigma_2(3\sigma_1^2-\sigma_2^2)$. Each satisfies its eigenvalue equation, and each family is linearly independent — checked by evaluating at a handful of well-chosen plane points.

### Which degree does the Mexican hat pick?

Because the connectivity kernel depends only on the distance between two points of the sphere, it cannot distinguish the members of one eigenspace: it multiplies every degree-$l$ harmonic by one number $\lambda_l$. (This is the classical Funk–Hecke phenomenon: a rotation-invariant kernel is diagonal in the spherical-harmonic basis.) For a difference-of-Gaussians Mexican hat of interaction radius $r$, that multiplier, normalised so its peak equals $1$, is the band-pass profile

$$\lambda_l(r) = g\big((lr)^2\big), \qquad g(s) = s\,e^{\,1-s}.$$

Three facts about $g$ settle mode selection, and each follows from the single inequality $t+1 < e^t$ for $t \ne 0$:

- **Sharp peak.** $g(1) = 1$, and $g(s) < 1$ for every $s \ne 1$.
- **Strict unimodality.** $g$ is strictly increasing on $[0,1]$ and strictly decreasing on $[1,\infty)$.
- **Bracketing of the winner.** For every radius $r>0$ and every degree $l$, $\lambda_l(r) \le \max\{\lambda_{\lfloor 1/r\rfloor}(r),\ \lambda_{\lceil 1/r\rceil}(r)\}$.

The selected degree is the integer whose product $lr$ lands closest to resonance, $lr \approx 1$. Since $l$ must be a whole number and $1/r$ generally is not, the winner is one of the two integers straddling $1/r$.

At the **resonant radii** $r = 1/k$ the ambiguity disappears completely: then $(kr)^2 = 1$ exactly, the degree-$k$ multiplier hits the peak value $1$, and every other degree is strictly below it. So:

> **Pattern-count theorem (resonant radii).** For $r = 1/k$ the Mexican-hat kernel strictly selects degree $N = k = \lfloor 1/r\rfloor$, and the selected eigenspace contains exactly $2N+1$ linearly independent stereographic patterns. For $k=1,2,3$ these are the $3$, $5$ and $7$ patterns listed above.

The count is not merely a lower bound. Within the polynomial ansatz that any truncated amplitude-equation model actually lives in, one can show it is *exact*: an affine function of the chart coordinates satisfies the degree-one equation if and only if its constant term vanishes (giving exactly $3$ solutions' worth of freedom); a general quadratic satisfying the degree-two equation must have no linear part and must have its constant term locked to minus one third of its trace, after which it lies in the span of the five quadrupoles; and a parity-odd cubic satisfying the degree-three equation lies in the span of the seven octupoles. Three degrees, three exact matches with $2l+1$. (Beyond those three, exact rational linear algebra on the full polynomial ansatz reproduces the count $2l+1$ for every degree up to six — strong evidence, though not yet a proof, that the pattern is universal.)

### Two places where the naive picture is wrong

Mathematics is at its most useful when it refuses to confirm a slogan. Two clauses of the intuitive story turn out to be false as stated, and their corrections are themselves informative.

**The winner is not always $\lfloor 1/r \rfloor$.** It is tempting to say "the selected degree is $N = \lfloor 1/r\rfloor$" for every radius. It isn't. At $r = 0.4$ we have $1/r = 2.5$, and the two candidates give $\lambda_2 = 0.64\,e^{0.36} \approx 0.917$ against $\lambda_3 = 1.44\,e^{-0.44} \approx 0.927$. The ceiling wins. The correct universal statement is the bracketing above; the floor is guaranteed only at the resonant radii.

**Not every pattern decays at infinity.** One naturally expects a projected pattern to fade as you move out in the plane, since going to infinity means climbing to the north pole. But a harmonic need not vanish at the north pole — and if it doesn't, the projected pattern converges to a nonzero constant. Concretely, along any ray $R \mapsto (Ru, Rv)$ with $u^2+v^2=1$, a general dipole $a\sigma_1 + b\sigma_2 + c\sigma_3$ satisfies

$$a\sigma_1 + b\sigma_2 + c\sigma_3 \;=\; c \;+\; \frac{2aRu + 2bRv - 2c}{1+R^2} \;\longrightarrow\; c,$$

with the explicit error bound $|{\cdot} - c| \le (2|a|+2|b|+2|c|)/R$. The zonal mode $\sigma_3$ tends to $1$; it does *not* decay. In fact a degree-one pattern decays along every ray **if and only if** its north-pole coefficient $c$ vanishes. Decay is thus a single linear condition, and the decaying part of the degree-$N$ pattern space has dimension $2N$, not $2N+1$. The patterns that *do* decay do so at sharp polynomial rates: the two-fold sectoral quadrupole obeys $|\sigma_1^2-\sigma_2^2| \le 8/R^2$, and the three-fold sectoral octupole obeys $|\sigma_1(\sigma_1^2 - 3\sigma_2^2)| \le 32/R^3$.

### Symmetry: why the patterns look the way they do

The reason the projected patterns *look* like hallucinations — fans, rosettes, pinwheels — is that plane rotations are sphere rotations in disguise. Rotating the plane by an angle $\theta$ is conjugated by the chart to rotating the sphere about its polar axis: the two horizontal coordinates transform by the standard rotation matrix,

$$\sigma_1 \mapsto \cos\theta\,\sigma_1 - \sin\theta\,\sigma_2, \qquad \sigma_2 \mapsto \sin\theta\,\sigma_1 + \cos\theta\,\sigma_2,$$

while the polar coordinate $\sigma_3$ is fixed. The degree-$l$ pattern space is therefore a rotation-invariant space: its members really are *rotational variants* of one another, which is precisely the sense in which there are $2l+1$ of them rather than one.

The sectoral patterns — the ones built purely from $\sigma_1$ and $\sigma_2$, that is, from $\mathrm{Re}(\sigma_1 + i\sigma_2)^l$ and $\mathrm{Im}(\sigma_1+i\sigma_2)^l$ — inherit exact discrete symmetry. The degree-two sectoral pattern $\sigma_1^2 - \sigma_2^2$ is invariant under the half-turn: two-fold symmetry. The degree-three pair $\sigma_1(\sigma_1^2-3\sigma_2^2)$ and $\sigma_2(3\sigma_1^2-\sigma_2^2)$ is invariant under rotation by $2\pi/3$: three-fold symmetry, verified by an exact algebraic identity in $\sqrt3$ expressing that the real and imaginary parts of a cube are unchanged when the base is multiplied by a primitive cube root of unity. The boundary case is instructive: the degree-one sectoral pattern is *odd* under the half-turn, $\sigma_1(-x,-y) = -\sigma_1(x,y)$, so its symmetry group is genuinely one-fold. These are exactly the $N$-fold rosettes of the form-constant catalogue.

There is one more symmetry, and it is a pretty one. **Kelvin inversion** of the plane, $p \mapsto p/|p|^2$ — the map that exchanges the inside and outside of the unit circle — is conjugated by the chart to the equatorial reflection $z \mapsto -z$ of the sphere. It fixes $\sigma_1$ and $\sigma_2$ and negates $\sigma_3$. So it pairs patterns of opposite polar parity: the zonal quadrupole $3\sigma_3^2-1$ is unchanged by inversion, while the zonal octupole $\sigma_3(5\sigma_3^2-3)$ changes sign. In perceptual terms: turning a pattern inside out through the unit circle is the same as flipping the cortical sphere north-for-south.

### Why this matters

The point of the construction is that it converts a soft statement — "cortical geometry constrains the hallucination repertoire" — into a countable prediction with an explicit dictionary. Fix the interaction radius $r$ of the cortical connectivity, which is measurable. The theory then says: the emergent pattern is a degree-$N$ mode with $N$ the integer nearest resonance ($N = \lfloor 1/r\rfloor$ when $r$ is a reciprocal integer, and one of $\lfloor 1/r\rfloor, \lceil 1/r\rceil$ otherwise); there are exactly $2N+1$ of them; $2N$ of those fade in the periphery and one does not; the sectoral ones have exactly $N$-fold rotational symmetry; and turning any of them inside out about the unit circle is a symmetry of the whole family.

None of this needs numerical solution of a partial differential equation on a curved surface. It needs one nineteenth-century map, one closure property of a three-symbol algebra, and one inequality about the exponential function. That is a good exchange rate.

And it leaves the frontier clearly marked. The exact $2l+1$ upper bound is established in degrees one, two and three, and confirmed by exact computation up to degree six; the general degree is a purely algebraic recursion waiting to be organised. The codimension-one nature of decay is settled in degree one; the general statement — that decay is vanishing at the north pole, and its rate is the order of vanishing there — is visible but unproved. And the entire analysis so far is about *existence* of patterns, not their *stability*: which of the $2N+1$ shapes a real cortex actually settles into is a question the linear theory poses and the nonlinear theory must answer.
