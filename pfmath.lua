local v3 = Vector3.new
local nv = v3()
local dot = nv.Dot
local atan2 = math.atan2
local cos = math.cos
local sin = math.sin

local err = 1.0E-10

function solve(a, b, c, d, e)
	if not a then
		return
	elseif a > -err and a < err then
		return solve(b, c, d, e)
	end
	if e then
		local k = -b / (4 * a)
		local p = (8 * a * c - 3 * b * b) / (8 * a * a)
		local q = (b * b * b + 8 * a * a * d - 4 * a * b * c) / (8 * a * a * a)
		local r = (16 * a * a * b * b * c + 256 * a * a * a * a * e - 3 * a * b * b * b * b - 64 * a * a * a * b * d) / (256 * a * a * a * a * a)
		local h0, h1, h2 = solve(1, 2 * p, p * p - 4 * r, -q * q)
		local s = h2 or h0
		if s < err then
			local f0, f1 = solve(1, p, r)
			if not f1 or f1 < 0 then
				return
			else
				local f = f1 ^ 0.5
				return k - f, k + f
			end
		else
			local h = s ^ 0.5
			local f = (h * h * h + h * p - q) / (2 * h)
			if f > -err and f < err then
				return k - h, k
			else
				local r0, r1 = solve(1, h, f)
				local r2, r3 = solve(1, -h, r / f)
				if r0 and r2 then
					return k + r0, k + r1, k + r2, k + r3
				elseif r0 then
					return k + r0, k + r1
				elseif r2 then
					return k + r2, k + r3
				else
					return
				end
			end
		end
	elseif d then
		local k = -b / (3 * a)
		local p = (3 * a * c - b * b) / (9 * a * a)
		local q = (2 * b * b * b - 9 * a * b * c + 27 * a * a * d) / (54 * a * a * a)
		local r = p * p * p + q * q
		local s = r ^ 0.5 + q
		if s > -err and s < err then
			if q < 0 then
				return k + (-2 * q) ^ 0.3333333333333333
			else
				return k - (2 * q) ^ 0.3333333333333333
			end
		elseif r < 0 then
			local m = (-p) ^ 0.5
			local d = atan2((-r) ^ 0.5, q) / 3
			local u = m * cos(d)
			local v = m * sin(d)
			return k - 2 * u, k + u - 1.7320508075688772 * v, k + u + 1.7320508075688772 * v
		elseif s < 0 then
			local m = -(-s) ^ 0.3333333333333333
			return k + p / m - m
		else
			local m = s ^ 0.3333333333333333
			return k + p / m - m
		end
	elseif c then
		local k = -b / (2 * a)
		local u2 = k * k - c / a
		if u2 < 0 then
			return
		else
			local u = u2 ^ 0.5
			return k - u, k + u
		end
	elseif b then
		return -b / a
	else
		return
	end
end

local math = {}; function math.trajectory(pp, pv, pa, tp, tv, ta, s)
	local rp = tp - pp
	local rv = tv - pv
	local ra = ta - pa
	local t0, t1, t2, t3 = solve(dot(ra, ra) / 4, dot(ra, rv), dot(ra, rp) + dot(rv, rv) - s * s, 2 * dot(rp, rv), dot(rp, rp))
	if t0 and t0 > 0 then
		return ra * t0 / 2 + tv + rp / t0, t0
	elseif t1 and t1 > 0 then
		return ra * t1 / 2 + tv + rp / t1, t1
	elseif t2 and t2 > 0 then
		return ra * t2 / 2 + tv + rp / t2, t2
	elseif t3 and t3 > 0 then
		return ra * t3 / 2 + tv + rp / t3, t3
	end
end

return math
