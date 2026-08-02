# A Square Root of Dimension Hidden in the Boolean Cube

Every digital decision can be pictured as a walk through a cube. A three-bit input occupies one of the eight corners of an ordinary cube; changing one bit crosses one edge. With $n$ bits, the picture becomes the $n$-dimensional Boolean cube $Q_n$, whose $2^n$ vertices are binary strings and whose edges join strings differing in exactly one coordinate.

This simple graph is a central stage for complexity theory. A Boolean function colors each vertex $0$ or $1$. Its **sensitivity** at a vertex is the number of one-bit changes that alter the function value; its maximum sensitivity is the largest such number over all inputs. Sensitivity measures local fragility: how many individual switches can flip the answer? Polynomial degree, by contrast, is global. Every Boolean function has a unique multilinear real polynomial agreeing with it on the cube, and its degree records the largest interaction among input coordinates.

The celebrated sensitivity theorem connects these scales. The algebraic engine behind its spectral proof is a specially signed version of the cube. That engine is our subject. Its remarkable feature can be stated in one line: a certain signed adjacency operator $A_n$ satisfies

$$
A_n^2=nI.
$$

It is literally a square root of dimension. This identity forces every eigenvalue to have magnitude $\sqrt n$, and immediately turns any upper estimate $|\lambda|\le s$ on a certified eigenvalue into the quadratic inequality $n\le s^2$. The signs are not decoration. Remove them, and the identity already fails on a square.

## Building the operator one dimension at a time

It helps to regard $Q_{n+1}$ as two copies of $Q_n$: a lower layer indexed by a new bit $0$, and an upper layer indexed by a new bit $1$. A real-valued signal on $Q_{n+1}$ is then a pair $(u,w)$, where $u$ lives on the lower layer and $w$ on the upper one.

Start with $A_0=0$. Define the next operator recursively by

$$
A_{n+1}(u,w)=(A_nu+w,\;u-A_nw).
$$

Equivalently, in block form,

$$
A_{n+1}=
\begin{pmatrix}
A_n&I\\
I&-A_n
\end{pmatrix}.
$$

The identity blocks represent the new edges joining corresponding vertices in the two layers. The lower copy retains the old signing, while the upper copy receives the opposite signing. That minus sign is the entire mechanism.

To see it at work, apply the operator twice:

$$
\begin{aligned}
A_{n+1}^2(u,w)
&=A_{n+1}(A_nu+w,\;u-A_nw)\\
&=(A_n(A_nu+w)+u-A_nw,\\
&\qquad A_nu+w-A_n(u-A_nw)).
\end{aligned}
$$

Linearity makes the mixed terms cancel. What remains is

$$
A_{n+1}^2(u,w)=(A_n^2u+u,\;w+A_n^2w).
$$

If $A_n^2=nI$, this becomes $((n+1)u,(n+1)w)$. Since the zero-dimensional case is immediate, induction proves the **Scalar-Square Theorem**:

> For every integer $n\ge 0$ and every real-valued signal $v$ on $Q_n$, the recursively signed adjacency operator satisfies $A_n(A_nv)=nv$.

The theorem is best understood as cancellation of two-step walks. The coefficient of $v(y)$ in $(A_n^2v)(x)$ is a signed count of length-two walks from $x$ to $y$. There are exactly $n$ backtracking walks from $x$ to itself, each contributing $+1$. If $x$ and $y$ differ in two coordinates, there are two routes around the corresponding square face. The canonical signing gives those routes opposite products, so they cancel. No other endpoint is reachable in exactly two steps. Thus only the diagonal contribution $n$ survives.

This is a discrete interference pattern. Two paths exist, but their signs act like opposite phases and erase one another. The same broad idea appears in error-correcting codes, quantum amplitudes, signal processing, and the algebra of anticommuting observables: structure can be created not by adding more paths, but by arranging cancellation among paths already present.

## A spectrum with nowhere to hide

An eigenvector is a nonzero signal $v$ whose shape is preserved by the operator: $A_nv=\lambda v$. Apply $A_n$ again. The scalar-square identity gives

$$
nv=A_n^2v=A_n(\lambda v)=\lambda A_nv=\lambda^2v.
$$

Because $v$ is nonzero somewhere, cancellation of that nonzero coordinate yields $\lambda^2=n$. We obtain the **Spectral Rigidity Theorem**:

> Every real eigenvalue $\lambda$ of the canonical signed adjacency operator on $Q_n$ that has a nonzero eigenvector satisfies $\lambda^2=n$. Hence, for $n>0$, every such eigenvalue is either $\sqrt n$ or $-\sqrt n$.

Most large matrices have complicated spectra. This matrix acts on a space of dimension $2^n$, yet its eigenvalues are trapped at only two locations. The exponential size of the cube has collapsed to a quadratic equation.

The numerical consequence is equally clean. Suppose a spectral argument produces a nonzero eigenvector with eigenvalue $\lambda$, while a combinatorial argument bounds its magnitude by a nonnegative integer $s$. Then

$$
n=\lambda^2=|\lambda|^2\le s^2.
$$

This is the **Spectral-to-Local Bound**:

> If $A_nv=\lambda v$ for a nonzero real signal $v$ and $|\lambda|\le s$, then $n\le s^2$.

In applications, $s$ is meant to arise from a local degree or sensitivity bound. The algebra supplies the unavoidable spectral magnitude $\sqrt n$; graph combinatorics supplies an upper bound; comparison forces a large local quantity. This separation of labor is one reason the method is powerful. The signed operator handles the global geometry, while the application need only connect its eigenvalue to local behavior.

The theorem here is the spectral core, not by itself the full degree–sensitivity theorem for Boolean functions. Completing that bridge requires defining a suitable induced subgraph from a Boolean function and proving that its density and local degrees produce the needed eigenvalue certificate. Distinguishing the completed core from this further bridge is mathematically important: the identity $A_n^2=nI$ is unconditional, whereas its deployment in a particular complexity bound needs additional arguments.

## Why ordinary adjacency fails

A tempting guess is that the phenomenon belongs to the cube itself and that any edge signs should work. The smallest interesting face disproves this.

Let $B_n$ be the ordinary unsigned adjacency operator, obtained from the same recursion but replacing the minus sign by a plus sign:

$$
B_{n+1}(u,w)=(B_nu+w,\;u+B_nw).
$$

Take $n=2$ and let $\mathbf 1$ be the constant signal with value $1$ at all four vertices of the square. Every vertex has two neighbors, so $B_2\mathbf 1=2\mathbf 1$. Applying the operator again gives

$$
B_2^2\mathbf 1=4\mathbf 1,
$$

whereas the proposed scalar-square identity would demand $B_2^2\mathbf 1=2\mathbf 1$. Therefore the **Unsigned Counterexample Theorem** states:

> The all-positive signing of the two-dimensional cube does not satisfy $B_2^2=2I$. Consequently, it is false that every signing of cube edges squares to dimension times the identity.

The path picture makes the failure visible. Between opposite corners of a square are two length-two routes. With all signs positive, they reinforce each other and contribute $2$ instead of canceling. The diagonal still records the two backtracking paths, but now unwanted off-diagonal terms remain.

This counterexample does more than reject an overambitious statement. It points toward the right replacement. On each square face, the product of the four edge signs should be negative. Then the two paths between opposite corners have opposite signed products. The canonical recursive signing has exactly this cancellation behavior. A natural next problem is to prove that this face condition is equivalent to $A^2=nI$ and then classify all such signings up to switching signs at vertices.

## Computation as a microscope

The recursion gives a direct experiment. Enumerate vertices by binary strings. Construct $A_0=[0]$, and repeatedly form

$$
A_{k+1}=
\begin{pmatrix}
A_k&I\\
I&-A_k
\end{pmatrix}.
$$

For each small $k$, matrix multiplication reveals $A_k^2=kI$ up to numerical roundoff, and an eigenvalue routine returns only values near $\pm\sqrt k$. Constructing the ordinary adjacency matrix instead exposes the failure on $Q_2$: its square has nonzero entries connecting opposite corners.

The cost also tells a story. A dense matrix has $4^n$ entries, so dense construction and multiplication soon become expensive. But the cube has only $n2^{n-1}$ edges. A matrix-free recursive application of $A_n$ uses about $n2^n$ arithmetic operations and only $2^n$ storage. The mathematics suggests the algorithm: exploit the layered block structure rather than pretending the operator is dense.

## From switching networks to robust decisions

Why care about such an operator beyond one proof technique? The cube is the natural state space whenever a system has many binary choices: components may be working or failed, voters may answer yes or no, features may be present or absent, and switches may be open or closed. Sensitivity asks whether a decision is robust under a single local disturbance. Spectral information summarizes the collective geometry of all those disturbances.

The signed operator should not be confused with a physical network containing negative wires. Signs are mathematical phases assigned to routes. Their purpose is to reveal cancellation hidden by ordinary counting. This resembles a common strategy across mathematics: enrich an object with orientation or phase, perform an algebraic calculation in which unwanted terms cancel, and then translate the result back into an unsigned combinatorial statement. The gain is compression. Instead of tracking exponentially many vertices separately, one proves one operator identity.

The exactness of the identity also matters. A rough estimate such as $\|A_n\|\ge c\sqrt n$ would lose a constant and obscure which part of an application is responsible for slack. Here the algebra contributes no loss at all: the certified magnitude is exactly $\sqrt n$. Any weakness in a later inequality must enter through the bridge from a Boolean function or induced subgraph to the spectral certificate. That clean accounting is useful when searching for tighter degree–sensitivity relationships.

## The broader lesson

The Boolean cube is enormous, but it is assembled from tiny square faces. The canonical signing coordinates those faces so that every off-diagonal two-step interaction disappears. From local cancellation comes a global operator identity; from that identity comes spectral rigidity; from rigidity comes a quadratic lower bound on any local parameter capable of controlling the eigenvalue.

That chain is the central result:

$$
\text{negative phase around faces}
\Longrightarrow A_n^2=nI
\Longrightarrow \lambda^2=n
\Longrightarrow n\le s^2.
$$

And the unsigned square supplies the warning label: without controlled signs, parallel routes add rather than cancel.

Future work can now proceed in several directions. One can connect this spectral certificate fully to Boolean polynomial degree and sensitivity, classify every scalar-square signing, determine eigenvalue multiplicities and the characteristic polynomial, develop restriction and interlacing theory for induced subgraphs, search small cubes for sharper constants, and ask which products of larger alphabets support analogous cancellation. Each direction begins with the same vivid idea: sometimes the shortest route to understanding a huge combinatorial object is to make its two-step paths cancel in pairs.
