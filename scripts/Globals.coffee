define ->
	ret =
		gutter: 10
		sqsize: 50
		up: 0
		u: 0
		right: 1
		r: 1
		down: 2
		d: 2
		left: 3
		l: 3
		limit: 4
		dur: 15
		randomDir: -> ~~(Math.random() * (g.limit))
		_dirstrs: ["U","R","D","L"]
		isHorizontal: (dir) -> !!(dir%2)
		truedir: (dir) ->
			mod = dir%ret.limit
			return ret.limit + mod if mod < 0
			return mod
		dirstr: (dir) -> ret._dirstrs[ret.trustr(dir)]
		bound: (n, min, max) -> Math.min(Math.max(n, min), max)
		end: (dn, n, low, high) ->
			return n unless dn
			return high if dn > 0
			return low
		gridloc: (n) -> n*(ret.sqsize+ret.gutter)
		deg: (dir) -> dir*90
		next: (dir) -> (dir+1)%(ret.limit)
		prev: (dir) -> if dir then dir-1 else ret.limit-1

	return ret