pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
-- orbital V1.0
-- by unitvector_j

t,f=true,false


-- all the global tables
bdists,sparkles={},{}

-- all the global bools
drawtraj,show_orb,show_lines,show_mini,music_on,hilo,zpaused=t,t,t,t,t,t,f


--strings
controls="      ⬆️  : ACCELERATE\n    ⬅️  ➡️: ROTATE SHIP\n      ⬇️  : SHOW/HIDE HUD \n\n    z: OPEN/CLOSE z-MENU \n    x: CONFIRM/SELECT"
empty_m=split("you ran out of energy!;YOUR MISSION UNFULFILLED, YOU;DRIFT INTO THE INKY BLACKNESS;OF SPACE, FOREVER...",";")
crashed_m,starhit_m={"you crashed!","THE WRECKAGE OF YOUR SHIP","WILL REMAIN HERE...FOREVER."},{"you collided with a star!","YOU MELT AND BECOME PART OF IT"}
land_app=split(",,approaching,planet",",")


function _init()
	cartdata"unitvector_orbital"
	thisrand,maxfuel,fuel=un_spl"0,1280,1280"
	
	local pals=split"1,4,8,9,11,12,13"
	for col in all(pals) do pal(col,col+128,1) end
	mainmenu_init()
end


function _update()
	orbit_music()
	update()
	if (fuel<=0 and not empty) empty=t;popuprect(empty_m,0,f)
end


function _draw()
 cls"0"
	draw()	
end

-->8
-- menu


local a,cx,cy,sunx,suny,dir,
grow,gch,pspeed,ncol,ccol=unpack(split"0.125,0,0,27,42,0,0,0,-4")


local dc,ccols,b_dust,f_dust={6,13,1},{1,3,0,1,0},{},{}


function mainmenu_init()
	pmode=3
	update,draw=mainmenu_update,mainmenu_draw
	for i=1,96 do	scans[i]=0 end
	make_player(un_spl"162,100,0,0,0.5")
	setup_stars(un_spl"127,127,480")
	camera(0,0)
end

function mainmenu_update()
	--[
	hs=abs(sin(a/2))
	a=(a+.008*hs*hs*hs+.0005)%1
	--a=a%1
	
	
	suny=42-grow/2
	--[
	cx,cy=64+56*cos(a),suny+1+16*sin(a)
	dir=atan2(cx-sunx,cy-suny)+0.03*hs
	spawn_dust(cx,cy,dir)
	move_dust(b_dust)
	move_dust(f_dust)
	--]]
	
	if btnp"5" then -- and not hid 
		sfx"36"
		if not begun then
			begun=t
			gch,ncol,ccol= unpack(dget"0"==1 and {5,13,3} or {4,3,13})
		else
			if (gch==4) reset_o(2);dset(0,0);script=1;for i=1,24 do artb[i]=0 end
			if (gch==5) watched=t
			sel=t
		end
		sfx3"41"
	elseif btnp"4" then
		hid=not hid
	end
end

function mainmenu_draw()
	draw_stars()
	draw_system()
	if (not hid) draw_choices()
	if (goto_orbit) orbit_init(f);particles={}
end
--[

function spawn_dust(_x,_y,_dir)
	for _i=1,2 do
		d={x=_x,y=_y,dir=_dir,age=(0.45+rnd"0.3")*hs*hs}
		if dir<0.5 then
			add(b_dust,d) 
		else 
			add(f_dust,d) 
		end 
	end 
end

function move_dust(dust)
	for _d in all(dust) do
		_d.x+=_d.age*5*cos(_d.dir+0.03*hs)*hs
		_d.y+=_d.age*5*sin(_d.dir+0.03*hs)*hs
		_d.age-=0.01
		if (_d.age<0) del(dust,_d)
	end 
end


function draw_dust(dust)
	for _d in all(dust) do
		pset(_d.x,_d.y,dc[ceil(3-_d.age*4)])
	end
end


function draw_system()
	draw_dust(b_dust)
	if (a<0.5) circfill(cx,cy,1,6)
	if (not hid) sspr(0,96,76,24,40,32-grow/2)
	circfill(sunx,suny,12,9)
	circfill(sunx,suny,11,10)
	draw_dust(f_dust)
	if (a>0.5) circfill(cx,cy,1,6)
end

function draw_choices()
	for _i=1,5 do
		ovalfill(-80+_i-grow*4,78+_i-grow,207-_i+grow*4,109-_i+grow,ccols[_i])
	end
	if begun then
		grow=min(grow+0.3,6)
		pspeed-=sel and 0.06or pspeed>=0 and pspeed or -0.064
		px+=pspeed
		if (px<-128) goto_orbit=t
		move_player();draw_player();draw_parts()
		if grow==6 then
			n_c()
			pressx=""
			?"new", 36,79,ncol
			local cocol=dget(0)==1 and ccol or 1
			?"continue",62,79,cocol
		end
	else
		grow,pressx=0,"  press x to begin\n\npress z to hide menu"
	end
	?pressx,24,85-grow,13
	local ly=92-grow
	line(18,ly,109,ly,1)
	line(18,ly+2,109,ly+2)
	line(12,ly+1,115,ly+1,3)	
end

function n_c()
	if btnp"1" and dget"0"==1 then
		gch,ncol,ccol=un_spl"5,13,3"
	elseif btnp"0" then
		gch,ncol,ccol=un_spl"4,3,13"
	end 
end
-->8
-- orbit_mode

local int_y,it=128,0
local introtext="mANY MILLENNIA AGO, A SIGNAL\nWAS RECEIVED FROM A DISTANT\nSTAR CLUSTER. aS SUDDENLY AS\nIT APPEARED, IT VANISHED,\nNEVER TO BE SEEN AGAIN.\n\niN THEIR BOUNDLESS CURIOSITY,\nHUMANITY SENT A SHIP,\nPILOTED BY AN ai, TO\nINVESTIGATE AND REPORT ITS\nFINDINGS.\n\n\n\n\n\n\n\n\n\ntHIS JOURNEY OF THOUSANDS OF\nYEARS ACROSS THE COLD GULFS\nBETWEEN THE STARS HAS\nFINALLY COME TO AN END.\n\n\n\nyOU HAVE ARRIVED.\n\n\n\nyOUR MISSION:\niNVESTIGATE THE PLANETS IN\nTHE STAR CLUSTER, FIND\nEVIDENCE OF INTELLIGENT\nLIFE, AND SEND A SIGNAL\nHOME.\n\n\n\n\n\ncONTROLS:\n\n"..controls.."\n\ngOOD LUCK."




function orbit_init(f_p)
	drawhud,showmap,drawtraj,empty,crashed,on_ending,approached=f,f,t,f,f,f,f
	pmode,tlim=1,1
	if f_p then
		launch()
	else
		make_player(un_spl"-63,0,0,12,.75")
		fuel=maxfuel
		if (dget"0"==0) thisrand,camx,camy=ceil(rnd"32000"),-127,-1960
		if (dget"0"==1) watched=t;load_game()
		build_cluster(thisrand)
	end
	local sx,sy=flr(px*.00390625)+128,flr(py*.00390625)+128
	setup_stars(sx,sy,240)
	update,draw,z_do=orbit_update,orbit_draw,togglezmenu
	set_arts()	
end
 

function orbit_update()
	pause=starhit or approached or zpaused or complete
	if not watched then
		camy+=.75
		move_player()
		if (btnp"5") camy=-64
		if (camy>-64) watched=t;save_game()
	else
		if zpaused==f then
			if (btnp"5") x_do()
			if (not pause) move_player()
			if (not empty) camx,camy=flr(px-64),flr(py-64)
		end
		if (btnp"4") z_do()
	end
	setup_ui()
	check_stars(camx+64,camy+64,180)
	camera(camx,camy)	
	if b_d[25]<3 and not complete then
		pang,complete=0.25,t
		local c=cocreate(ending)
		add(actions,c)
	end
end


function orbit_draw()
	draw_stars()
	if (not complete) draw_parts()
	if (not close) draw_bodies()
 if (script==9) vortex()
 draw_ui()
 
 if not mapopen then
		if (bs[cstar] and watched and show_mini) minimap(bs[cstar])
		if (not (starhit or approached)) draw_player()
	end
	if (not watched) then
		if (flash(0,1)==1) spr(35,camx+124,camy+124)
		int_y-=0.18
		printd(introtext,8,flr(int_y),3)
	end
end


function ending()
	local b,end_y=bs[25],128
	reset_o(3)
	move_player()
	px,py,mopen,z_do=b.x,b.y,t,dont
	yield()
	while sedge<64 do
		sedge+=.125
		yield()
	end
	while sedge>-4 do
		sedge-=1
		yield()
	end
	on_ending,draw_player=t,dont
	while sedge<192 do		
		sedge+=4
		yield()
	end
	while not btnp"5" do
		printd(un_spl"signal lost,42,62,3")
		yield()
	end
end

-->8
-- starfield
local xs,ys,v_stars=-1,-1

function check_stars(_x,_y,_snum)
	local sx,sy,xrem,yrem,ox,oy=flr(_x/256)+128,flr(_y/256)+128,(_x/256)%1,(_y/256)%1,xs,ys
	xs=xrem<0.5and-1or 0
	ys=yrem<0.5and-1or 0
	sx+=xs
	sy+=ys	
	if (sgn(ox)!=sgn(xs) or sgn(oy)!=sgn(ys)) setup_stars(sx,sy,_snum)
end

function setup_stars(_x,_y,_snum)
	v_stars={}
	for _i=0,1 do
		for _j=0,1 do
			local stars={}
			local gs=(_x+_i)..(_y+_j)..thisrand
			srand(gs)
			local bx,by=(_x+_i-128)*256,(_y+_j-128)*256
			for _i=1,_snum do
				local s={bx+flr(rnd"256"),by+flr(rnd"256"),rnd(split("1,1,1,1,1,1,1,1,1,1,4,6,7,12,13"))}
				add(stars,s)
			end
			add(v_stars,stars)		
		end
	end
end

function draw_stars()
	for _s in all(v_stars) do
		for _i=1,#_s do
			local p=_s[_i]
			pset(p[1],p[2],p[3])
		end
	end
end
-->8
-- bodies

b_d,b_a,artb,scans={},{},{},{}

cstar,cplanet,planets,g,curx,cury,curvx,curvy,curang,_a,sedge
=unpack(split"0,0,0,4,0,0,0,0,0,0,11")
plcols={{5,6},{2,8},{2,13}}
local sdists,trt,ingrav,
   wasgrav={},.02*sqrt(2),t,t


bs={} --bodies table


function spawn_body(mass,radius,x,y,bp_r,num)
	local bp_a,bp_n,bp_av={},{},{}
	for _i =1,#bp_r do
		planets+=1
		bp_n[_i],bp_av[_i]=planets,get_angvel(mass,bp_r[_i])
		bp_a[_i]=num==1 and 0.75 or rnd()
	end
	body={
		mass=mass,
		radius=radius,
		x=x,y=y,
		bp_r=bp_r,
		bp_a=bp_a,
		bp_av=bp_av,
		bp_n=bp_n
	}
	artp[num]=((num-1)%3==0 and num<25) and ceil(rnd(#bp_r)) or 0
	bs[num]=body
end

function bods_init()
	bs,sdists,artp,just_started,planets={},{},{},10,0
end

function build_cluster(rand)
	srand(rand)
	bods_init()
	redo=f
	spawn_body(10,10,0,0,{92,240},1)
	for _i=2,26 do
		local _planets,rad,n,pr,mass={},10,0,0,48
		if _i<25 then
			rad,n=6+rnd"24",ceil(rnd"4")
			for _p=1,n do
		 	pr+=rad+(256/n+rnd(248/n))
				add(_planets,pr)
			end
			mass=.01*rad*rad*rad
		end
		local xshift=flr(rnd"31000")
		local _x=-31000+xshift
		_x+=xshift
		local yshift=flr(rnd"31000")
		local _y=-31000+yshift
		_y+=yshift
		spawn_body(mass,rad,_x,_y,_planets,_i)
		if dget"0"==0 then
			for s=1,#bs do
				if s!=_i then
					local d,a=get_dist(bs[s],bs[_i],64,1)
					if (d<36) redo,thisrand=t,rnd(_x) break
				end
			end
		end
		if (redo) break
	end
	if (redo) build_cluster(thisrand)
end



function gravitate(pl)
	local vx,vy=pl.vx,pl.vy
	local isme=(pl.x==px and pl.y==py)
	just_started=max(0,just_started-1)
	ingrav=f
	for _i=1,25 do
		local bod=bs[_i]
		if b_d[_i] and b_d[_i]<360 then
			ingrav=t
			local dist,a=get_dist(pl,bod,8,1)
		 --star crash!
		 if dist<bod.radius*.125 then
		 	if not (isme or warned) then warned=t;popup("STELLAR COLLISION IMMINENT")
		 	elseif (isme and not empty and not close) then starhit=t;popuprect(starhit_m,0,f)
		 	end
		 end
		 local force=g*8*bod.mass/dist/dist
		 if (script<9 and _i==25) force=0
		 vx,vy=cossin(vx,vy,force*trt,a)
			if (isme) b_d[_i]=dist*2;b_a[_i]=a
		elseif isme then
			local fdist,fa=get_dist(pl,bod,512,128)
			b_d[_i],b_a[_i]=flr(fdist),fa
		end
	end
	
	
	if just_started==0 and not empty then
		if ingrav and not wasgrav then
			popup"ENTERING GRAVITY WELL"
		elseif not ingrav and wasgrav then
			popup"ENTERING INTERSTELLAR SPACE"
		end
	end
	wasgrav=ingrav
	return vx,vy
end


function get_dist(a,b,div,mult) --d
	local d=1/div
 local x,y=b.x*d-a.x*d,b.y*d-a.y*d
 local ang,sum=atan2(x,y),x*x+y*y
 if sum<0 then sum=32767 end
 return sqrt(sum)*mult,ang
end


function draw_bodies()
	local any=f
	cstar=0
	for _i=1,24 do
		if b_d[_i] and b_d[_i]<360 then
			local body=bs[_i]
			local bx,by,br=body.x,body.y,body.radius
			cstar=_i
			--draw the star
			circfill(bx,by,br,9)
			fillp"0b0101101010010101.1"
			circfill(bx,by,br-1,10)
			fillp()
			circfill(bx,by,br-3)
		
			-- planet logic
			for _j = 1,#body.bp_a do
				if (not pause) body.bp_a[_j]+=body.bp_av[_j]
				local bang,rad=body.bp_a[_j],body.bp_r[_j]
				local pl_x,pl_y=cossin(bx,by,rad,bang)
				local planet={x=pl_x,y=pl_y}
				if(show_orb and (scans[body.bp_n[_j]]==1 or script>3)) circ(bx,by,rad,1)
				local z,rind=unpack(rad<120 and {2,1} or rad>420 and {7,3} or {4,2})
				
				--draw the planet
				circfill(pl_x,pl_y,z,plcols[rind][1])
				fillp"0b0100001010000001.1"
				circfill(pl_x,pl_y,z,plcols[rind][2])
				fillp()
				
				--planet detection
				local mdist = get_dist({x=px,y=py},planet,8,1)
				if watched then
					local pl_r=0
					-- planet in scan distance
					if mdist<6 then
						inscan,any,cplanet=t,t,_j
						pl_r=2+rind*2
						local pl_d=pl_r*2+1
						sspr(0,8,17,17,pl_x-pl_r,pl_y-pl_r,pl_d,pl_d)
					end
					-- prep for land mode
					if mdist<pl_r*.125 then
					 if (not approached) transition("planet",rind,has_art())
					 local r=rad+6+3*rind
					 inscan,approached,from_planet=f,t,t
					 avel=get_angvel(body.mass,r)*100
					 curang=bang+.25
					 curx,cury=cossin(pl_x,pl_y,6+rind*2,bang)
					 curvx,curvy=cossin(0,0,r*avel,curang)
					 set_grav(rind)
					end
				end
			end
		end
	end	
	if (not any) inscan=f;cplanet=0
	if (inscan and not wasscan) local _num=bs[cstar].bp_n[cplanet];popup_s(_num,has_art())
	wasscan=inscan
end


function launch()
	make_player(curx,cury,curvx,curvy,curang)
end


function get_angvel(m,r)
	--     \_(ツ)_/
	return .311126*sqrt(m/r)/r
end


function has_art()
	return artp[cstar]==cplanet
end

function vortex()
	close=f
	local ab=bs[25]
	_a+=.0125*(1-sedge/96)
	if b_d[25]<142 then
		close=t
		fuel+=0.5
		show_lines,drawtraj,drawhud=f,f,f
		spiral_in(ab.x,ab.y)
		local _s=sedge/1.5
		for i=1,8 do
			ax,ay=cossin(ab.x,ab.y,8+_s,i*.125+_a)
			sspr(64,0,11,13,ax-5,ay-6)
		end
	end
end

function spiral_in(x,y)
	for i=1,2 do
		for _j=1,3 do
			local _c=i%2==0 and 12 or 3
			local s={d=92*_j+rnd"128",a=rnd(),c=_c,sp=2.5}
			local s2={d=52+_j*12,a=rnd(),c=_c,sp=0.375}
			if not on_ending then
				add(sparkles,s2)
				add(sparkles,s)
			end
		end
	end
	circfill(x,y,180,0)
	for _s in all(sparkles) do
		_s.a+=.625/_s.d
		_s.d-=_s.sp
		local sx,sy=cossin(x,y,_s.d,_s.a)
		local c=_s.d<24 and 11 or _s.d<256 and _s.c or 1
		pset(sx,sy,c)
		if(_s.d<sedge) del(sparkles,_s)
	end
	circfill(x,y,16,0)
end

function set_arts()
	for i=1,24 do
		if (artb[i]==1) artp[i]=0
	end
end
-->8
-- player

totvel,flx,fly,mapopen,pang,px,py,pvx,pvy=0,0,0,f

local angvel,thrust,exhaust,gr,particles,shipscale,extend,l_l=.01,{0.024,0.48},{896,64,72},{0.1,0.2,0.4},{},{5,7,10},0,7



function make_player(x,y,vx,vy,ang)
	pang,px,py,pvx,pvy=ang,x,y,vx,vy
end


function move_player()
	move_parts()
	touching=f
	if pmode==3 then
		xsc,ysc,sizex,sizey=-1,0,-shipscale[pmode]/3,0
		spawn_parts(px+8,py+1.5,24,0,1,0.5)
	else
	 xsc,ysc=cossin(0,0,1,pang)
	 if watched and fuel>0 and not mopen then
			
			--⬅️➡️⬆️⬇️
			if (not touching) pang+=btn"0" and angvel or  btn"1" and -angvel or 0
			if (btn"2" and not locked) then
				sfx(35,3,6+ceil(rnd"6"),3)
				local tmult=script>2 and 0.5 or 1
				if (script>6) tmult=0
				local tmode=hilo and 2 or 1
				fuel-=0.25*tmode*tmult
				local xthrust,ythrust=cossin(0,0,thrust[pmode]*tmode,pang)
				pvx+=xthrust
				pvy+=ythrust
				local exh=exhaust[pmode]
				if (tmode==2) exh*=.75
				spawn_parts(px+pvx*.0625,py+pvy*.0625,-xthrust*exh,-ythrust*exh,xsc,ysc)
			elseif (btnp"3") then
				drawhud=not drawhud
			end
		end
		
		if pmode==1 then
			pvx,pvy = gravitate({x=px,y=py,vx=pvx,vy=pvy})
		elseif pmode==2 then
			pvy+=gravity
			if pang<-.25 then pang+=1
			elseif pang>.75 then pang-=1
			end
			exiting=f
			
---- exit to orbit -------------			

			if py<-1200 or px<100 or px>30620 then
				exiting=t
				transition("orbit",1,f)
			end
			
---------------------------------
			extend=shifter(py>-128,extend,1,0.02)
		end
		
		vm=pmode==1 and 1.2 or 0.225
		px+=(pvx*.0625)
		py+=(pvy*.0625)
		flx,fly=flr(px),flr(py)
		local _pvx,_pvy=pvx*vm,pvy*vm
		local speed=sqrt(_pvx*_pvx+_pvy*_pvy)*3
		local v=flr(speed*10)
		local vrem=v%10
		totvel=flr(speed).."."..vrem

		sizex,sizey=cossin(0,0,shipscale[pmode]/3,pang)
		
		if pmode==2 and not exiting then
			local p_cos,p_sin=cossin(0,0,1,pang+.375)
			local n_cos,n_sin=cossin(0,0,1,pang-.375)
			
			lfx,lfy=flx+l_l*p_cos*extend,fly+(l_l-1)*p_sin*extend
			rfx,rfy=flx+(1+l_l)*n_cos*extend,fly+(l_l-1)*n_sin*extend
			local l_on,r_on=hit_ground(lfx,lfy),hit_ground(rfx,rfy)
			
			if (l_on or r_on) touching,totvel,pvx,pvy=t,0,0,0
			on_g=f
			if(l_on and r_on) then
				on_g=t
				if not absorbing then
					absorbing=t
					local c=cocreate(absorb_ore)
					add(actions,c)
				end
				px=lfx-l_l*p_cos
				py=lfy-(l_l-1)*p_sin
			elseif l_on then
				pang-=mid(-0.03,0.03*cos(pang-0.125),0.03)
				px,py=ceil(lfx)-(l_l+1.5)*p_cos,ceil(lfy)-l_l*p_sin
				
			elseif r_on then
				pang-=mid(-0.03,0.03*cos(pang+0.125),0.03)
				px,py=ceil(rfx)-(l_l+1.5)*n_cos,ceil(rfy)-l_l*n_sin
			else
				touching,absorbing=f,f
			end
			if isclose() and on_g and artb[cstar]==0 then
				read_script(script)
			end
		end
	end
end

function draw_player()
	local pvtx=flr(px)-xsc
	local pvty=flr(py)-ysc
	local wide=shipscale[pmode]
	local nosex,nosey=pvtx+sizex*3,pvty+sizey*3 
	local clx,cly,crx,cry=pvtx+sizey,pvty-sizex,pvtx-sizey,pvty+sizex
		--legs
	if pmode==2 then
		line(clx,cly,lfx,lfy,6)
		line(crx,cry,rfx,rfy,6)
	end	
	
	--  filler
	circfill(pvtx,pvty,1,1)
	
	-- ship's body
	for _i=wide*2,1,-1 do
		line(pvtx+_i*ysc/6,pvty-_i*xsc/6,nosex,nosey,1)
		line(pvtx-_i*ysc/6,pvty+_i*xsc/6,nosex,nosey,1)
	end
	
	local u,r=pvtx+2*xsc+0.25,pvty+2*ysc+0.25
	circfill(u,r,wide*.125,9)
	circfill(u-xsc,r-ysc,wide/6,8)
	
	--cockpit
 if (pmode!=1) pset(u,r)
	
	--nose
	pset(nosex,nosey,9)
	
	--base corners
	pset(clx,cly)
	pset(crx,cry)
if (pmode==2 and not crashed) check_crash(nosex,nosey)
end

function check_crash(nx,ny)
if (ny>get_glevel(nx)and not empty)crashed=t;popuprect(crashed_m,0,f)
end

function spawn_parts(x,y,vx,vy,xs,ys)
	for _i=0,3 do
		local x_offset=ys*(-0.8+rnd"1.6")
		local y_offset=xs*(-0.8+rnd"1.6")
		part={sx=x+x_offset-_i*xs,
      sy=y+y_offset-_i*ys,
      svx=pvx*.06+(vx*.0625)+x_offset*.2,
      svy=pvy*.06+(vy*.0625)+y_offset*.2,
      maxage=20+rnd"30",
      age=0}
		add(particles,part)
	end
end

function move_parts()
	for _p in all(particles) do
		_p.sx+=_p.svx
		_p.sy+=_p.svy
		_p.age+=1
		if _p.age > _p.maxage then
			del(particles,_p)
		end
	end
end


function draw_parts()
	if pmode==1 then
		circfill(bs[25].x,bs[25].y,128,0)
	end
	for _p in all(particles) do
		local pa,pma=_p.age,_p.maxage
		local _pcol=(pa<pma*.125 and hilo) and 3 or pa<pma*.25 and 12 or pa<pma*.5 and 1 or 0
		fillp(0b0101101010010100.1)
		circfill(_p.sx,_p.sy,flr(1.7*pa/pma),_pcol)
		fillp()
	end
end


function set_grav(ind)
	gravity=gr[ind]
end


function warp()
	warping=t
	popup"PRESS x TO OPEN SLIP TUNNEL"
	local _t,x,y=0,0,0
	yield()
	while true do
		x,y=cossin(0,0,32,pang)
		circ(flx+x,fly+y,1,3)
		if (btnp"5" and not zpaused) break
		yield()
	end
	locked=t
	popup"PRESS x TO DISENGAGE"
	pvx,pvy=x*16,y*16
	yield()
	while not ingrav do
		_t+=1
		local _c=_t%6==0 and 3 or 12
		if (_t%3==0) warp_it(x,y,_c)
		if (btnp"5" and not zpaused) break
		yield()
	end
	locked=f
	warping=f
	pvx*=.015625
	pvy*=.015625
end


function warp_it(x,y,_c)
	local scale=1.125
	local c =cocreate(
	function()
		while scale>-1 do
			scale-=0.0625
			circ(px+x*scale,py+y*scale,ceil(8-abs(scale)*7),_c)
			yield()
		end
	end)
	add(actions,c)
end

function x_do() end
function z_do() end

-->8
-- land mode


function land_init(_t,hasart)
	pl_type,exited,pmode,tlim,drawtraj,extend=_t,f,2,2,f,0
	traj={}
	update,draw,z_do=land_update,land_draw,togglezmenu
	make_player(un_spl"15660,-360,20,28,0.32")
	setup_stars(flr(px/256)+128,flr(py/256)+128,180)
	set_ground(hasart)
end



function land_update()	
	if not (zpaused or crashed or exiting) then
		move_player()
		if (not empty) camx,camy=px-64,py-64
		camera(camx,camy)
		check_stars(px,py,180)
	end
	if (btnp"4") z_do()
	if (btnp"5") x_do()
	setup_ui()
end


function land_draw()
	draw_stars()
	if (has_art()) artshow()
	draw_parts()
	if (show_mini and not mopen) elev_map(pl_type)
	draw_ground(pl_type)
	draw_ui()
	if (not (exiting or crashed or mapopen)) draw_player()
 if (has_art()) draw_art()
	if exited then
		exiting=f
		g_init()
		orbit_init(t)
	end
end
-->8
-- ground

local g_top,g_bot,arta,_act=92,360,0,0


function g_init()
	mapheights,g_h,slopes,orelocs,map_ores={},{},{},{},{}
end

function set_ground(hasart)
 g_init()
	local down=t
	g_h[0],g_limit,slopes[-1]=180,48,0
	local grand=flr(thisrand)..cstar..cplanet
	srand(grand)
	-- do the random stuff like with the stars
	local smooth=rnd"0.5"
	
	for _i=1,3840 do
		local g_change=rnd"12"*abs(sin(_i*.02777778))*(1-smooth*abs(sin(_i*.003649635)))
		if(down)g_change=-g_change
		g_h[_i]=g_h[_i-1]-g_change
		slopes[_i-1]=-g_change*.125
		if _i>g_limit then
			down=not down
			g_limit+=4+flr(rnd"40")
		elseif g_h[_i]<g_top then
			down=t
		elseif g_h[_i]>g_bot then
			down=f
		end
		local map_has_ore=f
		if _i%2==0 then
		 if rnd() < 0.025 then
			 make_ore(_i,g_h[_i])
			 map_has_ore=t
		 end
		 add(mapheights,g_h[_i])
			add(map_ores,map_has_ore)
		end
	end
	if hasart then
		artx=1320+ceil(rnd"1120")
		arty=g_h[artx]-42
	else
		artx=-64
	end
end

function get_glevel(_x)
	local v,j=flr(_x*.125),_x%8
	return g_h[v]+slopes[v]*j
end

function draw_ground(_plt)
	for _i=0,#g_h-1 do
		if(_i>(camx-8)*.125
			and _i<(camx+128)*.125) then
		 for _j=0,7 do
				local _x=(_i*8+_j)
				local scale,_h=sin(_x*.00390625),get_glevel(_x)
				local boop=_h*.05
				line(_x,_h,_x,_h+128,plcols[_plt][2])
				line(_x,_h,_x,_h+36-boop-boop*scale,plcols[_plt][1])
			end
		end
	end
	draw_ore()
end

function isclose()
	return abs(px-12-artx*8)<48
end

function artshow()
	arta=(arta+0.0078125)%1
	ax,ay=(artx)*8-1,arty+2*cos(arta)+8
	_act=(_act+1)%64
	fillp(0b0101101001101001.1)
	circ(ax,ay,(time()*400)%4800,3)
	circ(ax,ay,16-_act*.25,3)
	circ(ax,ay,16+_act,1)
	fillp()
	circ(ax,ay,16,11)
end


function draw_art()
	palt(0,f)
	palt(10,t)
	sspr(75,0,25,31,ax-12,ay-7)
	palt(0,t)
	palt(10,f)
end

function hit_ground(x,y)
	local hit=f
	hit=flr(y)>get_glevel(x)-1
 return hit
end

function make_ore(_x,_h)
	local ores=4+ceil(rnd"3")
	for _i=1,ores do
		local oreloc= {s=ceil(rnd"5"),x=_x*8-16+rnd"32",y=_h+4+rnd"16"}
		add(orelocs,oreloc)
	end
end

function draw_ore()
	for o in all(orelocs) do
		spr(o.s,o.x,o.y)
	end
end


function absorb_ore()
	for o in all(orelocs) do
		if abs(o.x-px)<48 and fuel<maxfuel then
			for _l=1,30 do
				for _j=0,2 do
					line(px,py,o.x+3+4*sin(_l*.03333334+0.325*_j),o.y+3,3)
				end
				yield()
			end
			del(orelocs,o)
			fuel=min(maxfuel,fuel+64)
		end		
	end
end

-->8
-- ui

tlim,hide_hud,
drawhud=1,12,t

local traj,maxtraj,pop,uix,uiy={},92,f,0,0


function setup_ui()
	setup_zmenu()
	if not zpaused then
		tlim=shifter(not drawtraj,tlim,1,0.03)
		if (tlim<1 and not starhit and pmode==1) plot_traj()
	end
	if (starhit or empty) traj={}
	stretch_map()
	uix,uiy=camx-hide_hud,camy-hide_hud*.8
end


function draw_ui()
	if (pmode==1 and not empty) then
		for _i=1,24 do
			if (watched) draw_bodylines(_i)
		end
		if (not starhit) draw_traj()
	end
	do_cos()
	if (mapopen) show_map()
	
	if (not empty) draw_hud();draw_zmenu()
end

function draw_hud()
	hide_hud=shifter(not drawhud,hide_hud,12,1)
	if hide_hud<12 then
		draw_panel(-1,0,0,0)
	 draw_panel(13,-1,54,1)
		draw_fuelbar()
		draw_velocity()
	end
end


function draw_panel(x,y,l,o)
	local _x,_y=uix+x,uiy+y-3
	for _i=1,#rcol do
		if o==1 then
			rectfill(_x-_i,_y+_i,_x+l-_i,_y+14-_i,rcol[_i])
			circfill(_x+l-1,_y+7,7-_i)
		else
			circfill(_x,_y+38,14-_i,rcol[_i])
		 rectfill(_x,uiy+8*((_i+1)%2),_x+14-_i,_y+40-_i)
		end
	end 
end

--planet scan popup
function popup_s(num,has)	
	local c=cocreate(
	function()
		local y,found,no,m,_t=0,"ARTIFACT DETECTED","NO ","",0
		while t do
			if inscan then
				pop=t
				y=min(11,y+1)
				if scans[num]==0 then
					if (not zpaused) _t+=1
					m="SCANNING PLANET: ".._t.."%"
		 		if (_t==100)	scans[num]=1
		 	else
		 		m=not has and no..found or found
		 	end
		 else
		 	if y>-1 then 
		 		y-=1
		 	else 
		 		warned=f
		 		break
		 	end
		 end
		 draw_panel(14,y-2-morehide,#m*4-3,1)
	 	uiprint(m,14,y-morehide,3)
	 	yield()
		end
		pop=f
	end)
	add(actions,c)
end


function popup(m)
	local c=cocreate(
  function()
  	local y,tmax=0,120
  	for _t=1,tmax do
  		y=shifter(_t<110,y,11,1)
   	local qy=pop and y+9 or y-2
   	draw_panel(14,qy,#m*4-3,1)
   	uiprint(m,14,qy+2,flash(3,13))--8187
   	yield()
			end
			warned=f
  end)
 add(pops,c)
end

function flash(a,b)
	return time()%1>.7 and b or a
end

function popuprect(m,r,bo)
	local c=cocreate(
		function()
			local _x,_y,_i,e,ti=4,4,1,f,time()
			if r==0 then
				x_do=(function() orbit_init(f);e=t end)
				z_do=(function() run() end)
			else
				x_do,z_do=dont,dont
			end
			while t do
				uirect(64-_x,24,_x*2,#m*6+30,3)
				if (r>0 and time()>ti+2) then
					e=t
					if pmode==1 then
						land_init(r,bo)
					else
						exited=t
						particles={}
					end
					x_do=dont
				end
				if (_x<68) then
					_x+=4
				else
					printd(m[1],64-#m[1]*2,30,3)
					for i=2,#m do
						printd(m[i],64-#m[i]*2,27+6*i,3)
						if (r==0) printd("PRESS x TO RELOAD\n PRESS z TO QUIT",30,36+6*#m,3)
					end
				end
				if (e) break
				yield()
			end
		end)
	add(actions,c)
end


function draw_fuelbar()
	--fuel background
	uishift(rectfill,1,2,3,42,1)
	-- fuel
	local kcol={12,11,3}
	for k=1,3 do
		uishift(line,k,mid(1,42+k-flr(fuel*.035714285),43),k,43,kcol[k])
	end	
	--around fuel
	uishift(rect,0,1,4,43,5)
	for _i = 1,6 do
		uiprint(sub("ENERGY",_i,_i),6,_i*6-3,13)
	end
end

function uiprint(m,x,y,c)
	p_shadow(m,uix+x,uiy+y,c)
end

function uishift(func,x,y,xx,yy,c)
	func(uix+x,uiy+y,uix+xx,uiy+yy,c)
end

function draw_velocity()
	local unit={"KM/S","M/S"}
	local label="VEL:      "..unit[pmode]
	local v=tostr(totvel)
	uiprint(label,12,1,13)
	if locked then
		alien_script(9)
	else
	uiprint(v,51-4*#v,1,3)
	end
end


function plot_traj()
	local _t={x=px,y=py,vx=pvx,vy=pvy}
	traj[0]={x=_t.x,y=_t.y}
	for _i=1,maxtraj do
		_t.vx,_t.vy = gravitate(_t)
		_t.x+=_t.vx*.0625
		_t.y+=_t.vy*.0625
		local new={x=_t.x,y=_t.y}
		add(traj,new)
	end
end

function draw_traj()
	if #traj>7 then
		for _i=#traj-1,7,-1 do
			local tc=_i<maxtraj*.2 and 9 or _i<maxtraj*.4 and 8 or _i<maxtraj*.6 and 2 or 1
			if ((tlim+rnd".9")<1-(_i/maxtraj)) line(traj[_i].x,traj[_i].y,traj[_i+1].x,traj[_i+1].y,tc)
		end
	end
	traj={}
end


function draw_bodylines(i)
	local d,a=b_d[i],b_a[i]
	if d and d<2400 and d>24 and show_lines then
		local bc,bsz=unpack(d<366 and {3,1} or d<900 and {13,1} or {1,0})
		d*=.00694444
		blx,bly=cossin(flx,fly,42+d,a)
		blxx,blyy=cossin(flx,fly,61,a)
		line(blx,bly,blxx,blyy,bc)
		circ(blx,bly,bsz,9)
		circ(blx,bly,bsz-1,10)
	end
end


function minimap(_b)
	local cx,cy=camx+110.5,camy+110.5
	local br,ba=_b.bp_r,_b.bp_a
	local a=b_a[cstar]+.5
	local mpx,mpy=cossin(cx,cy,min(17.5,b_d[cstar]*.1111111),a)
	for _i=1,3 do
		circfill(cx,cy,19-_i,rcol[_i])
	end
	circfill(cx,cy,1,10)
	for _j=1,#br do
		if (scans[_b.bp_n[_j]]==1 or script>3) circ(cx,cy,br[_j]*.02777778,1)
		local plx,ply=cossin(cx,cy,br[_j]*.027777778,ba[_j])
		pset(plx,ply,7)
	end
	pset(mpx,mpy,9)
end

function elev_map(pl_type)
	local cs=plcols[pl_type]
	uirect(1,5,126,27)
	local _py=flr((py-304)*.02631579)
		local start_i=flr(px*0.05859375)-1
		for _i,_h in ipairs(mapheights) do
			if _i>=start_i and _i<(start_i+121) then
				local hgt=6+flr(_h*.0625)-_py
				local _my=camy+hgt
				local _mx=camx+4+_i-start_i
				if hgt>6 and hgt<33 then
					if hgt<30 then
						--underground
						line(_mx,_my,_mx,camy+29,cs[2])
						--surface
						pset(_mx,_my,cs[1])
					end
					
					--ores
					if (map_ores[_i-1] and hgt<29) circfill(_mx-1,_my+1,1,12)
					
					--artifact
					if (flr(artx*.5)==_i and artp[cstar]>0)circ(_mx-1,_my-3,1,3)
				end
			end
		end
		-- player dot
		if (py>-152) pset(camx+5+flr(px*.00390625),camy+5+flr(py*.0625)-_py,9)
end



function transition(word,n,b)
	drawhud=f
	reset_o(pmode)
	land_app[4]=word
	popuprect(land_app,n,b)
end
-->8
-- z window

--zopen=f
local zx,zlx,msel,mx,my,zlocx,zlocy,zbool=4,4,1,64,64,0,0

local zchoice,zmc
local offs=split("0,64,64,64,64")

morehide=0

function setup_zmenu()
	local xmax=76
	if zopen then
		for i=1,#offs do
			offs[i]=shifter(i!=zmc,offs[i],64,8)
		end
		zlx=offs[zmc]
	end
	zx=shifter(zopen,zx,xmax,16*cos(zx/(xmax*4+1)))
	zpaused=zx>0 or mapopen
	zlocx,zlocy=camx+zx+4,camy+64
	
	if zpaused then
	 
	 zchoice=btnp"2" and max(1,zchoice-1) or btnp"3" and min(zchoice+1,4) or zchoice
		if (btnp"0" or btnp"1" or btnp"2" or btnp"3")sfx"40"
		
		if btnp"5" then
			sfx3"36"
			-- main choices
			
			if zmc==1 then
				zmc=zchoice+1
				zchoice=1

		-- map
			elseif zmc==2 then
				if(zchoice==1) open_map()
			 if(zchoice==2) show_mini=not show_mini
			 if(zchoice==3) dont()--script=script<9 and script+1 or 1

		-- engine
			elseif zmc==3 then
				if(zchoice==1) hilo=t
			 if(zchoice==2) hilo=f
			 if(zchoice==3 and script>4) then
			 	togglezmenu()
			 	if not (ingrav or warping) then
			 		local c=cocreate(warp)
			 		add(actions,c)
			 	elseif ingrav then
			 		popup"cANNOT SLIP IN GRAVITY WELL"
					elseif warping then
						dont()
					end
    end

		--display
			elseif zmc==4 then
				if (zchoice==1)drawtraj=not drawtraj
				if (zchoice==2)show_orb=not show_orb
				if (zchoice==3)show_lines=not show_lines


		--options
			elseif zmc==5 then			 
			 if(zchoice==1)music_on=not music_on
			 if(zchoice==2)save_game()
			 if(zchoice==3)run()
			end
			if (zchoice==4 and zmc!=1) zmc=1
		end
	end
	zbool={{f,show_mini,f},{hilo,not hilo,f},{drawtraj,show_orb,show_lines},{music_on,f,f}}
end

function open_map()
	had_hud=drawhud
	drawhud,zopen,showmap=f,f,t
end



function show_options(ox,oy)
	local _y=oy-22
	local _ops=split("STELLAR\n CARTOGRAPHY,ENGINE\n SETTINGS,VISUAL\n INTERFACE,OPTIONS:STAR\n   CHART,MINI-\n   MAP\n,BOOP!,BACK:HIGH\n  POWER,LOW\n  POWER,OPEN SLIP\n  TUNNEL,BACK:TRAJECTORY\n PROJECTION,ORBITAL\n PATHS,STELLAR\n VECTORS,BACK:MUSIC\n(OFF/SKIP),SAVE\n GAME,EXIT TO\n TITLE,BACK",":")
	local _options={}
	for i=1,#_ops do
		_options[i]=split(_ops[i])
	end
	if (script<5) _options[3][3]=" ---"
	
	
	
	
	
	--_options[2][3]="".._options[2][3].." "..script
	--load up menu options
	local options=_options[zmc]
	for _o=1,4 do
		for _j=1,5 do
			local col=(_j>1 and zbool[_j-1][_o]==t) and 3 or 13
			p_shadow(_options[_j][_o],ox-3-offs[_j],_y+18*_o,col)
		end
	end
	-- selection cursor lines
	local x1,y1=ox-8-zlx,_y+zchoice*18+2
	line(x1-8,oy+20,x1,oy+20,3)
	line(x1,oy+20,x1,y1)
	line(x1,y1,x1+3,y1)
end



function draw_zmenu()
	local zx,zy=zlocx,zlocy
	if (not zpaused or mapopen) zx-=hide_hud
	if zx then
		-- z-tab
		for _i=1,3 do
			circfill(zx,zy,6-_i,rcol[_i])
			rectfill(zx-6,zy-6+_i,zx,zy+6-_i,rcol[_i])
		end
		?"z",zx-2,zy-2,3
		--end z-tab

		--the rest of the zwindow
		if zpaused then
			
			--background
			uirect(zx-camx-85,52,69,82)
			
			-- circle around player
			local z=zx-16
			circ(z,zy,13,1)
			circfill(z,zy,11,0)
			circ(z,zy,12,11)
			show_options(zx-68,zy+2)
		end
	end
end


function show_map()
	
	mapopen= mx!=60 and t or f	
	//black background
	rectfill(camx+mx-8,camy+my-8,camx+136-mx,camy+136-my,0)
	
	local locs={}
	morehide=shifter(showmap,morehide,12,2)
	if mx==0 then
			
		--== system view	==--
		local _y=camy+117.5
		local b=bs[msel]
		
		--draw the star
		local rad=2+flr(b.radius*.2)
		circfill(camx+3,_y,rad,9)
		circfill(camx+3,_y,rad-1,10)
		--draw the planets
		local expl=f
		for _pl=1,#b.bp_r do
			local scanhas=scans[b.bp_n[_pl]]==1
			if scanhas or script>3 then
				expl=t
				local r=b.bp_r[_pl]
				local rc,sz,_x,rs=5,0,camx+3,r*.210526316
				if r>420 then rc,sz=14,2
				elseif r>120 then rc,sz=8,1
				end
				circ(_x,_y,rs,1)
				circfill(_x+rs,_y,sz,rc)
				--indicate artifact
				if((scanhas or script>3) and _pl==artp[msel]) spr(19,_x+rs-3,_y-3)
			end
			if (not expl) printd("UNEXPLORED",44,115,3)
		end
		-- rect around system view
		for _i=1,2 do
			rect(camx-1+_i,camy+105+_i,camx+128-_i,camy+129-_i,rcol[_i])
		end
	
		--== main map ==--
		uirect(mx+8,my-1,110-mx*2,108-my*2)
	 -- if pmode==1
		
		local plocx,plocy=flr(px*1.0015625),flr(py*1.0015625)-10
		
		nbods=script==9 and 25 or 24
		
		--stars
		for _i=1,nbods do
		 local bod=bs[_i]
			local slocx=px+flr(bod.x*.0015625)
			local slocy=py+flr(bod.y*.0015625)-10
			local loc={x=slocx,y=slocy}
			locs[_i]=loc
			local _cc= _i<25 and 10 or 12
			circ(slocx,slocy,1,1)
			if (pmode==2 and _i==cstar)plocx=slocx;plocy=slocy
			pset(slocx,slocy,_cc)
			// draw the selection reticule
			if (msel==_i)sspr(0,8,17,17,slocx-3,slocy-3,7,7)
			// draw the artifact indicators
			if(artp[_i]>0 and script>3) spr(20,slocx-3,slocy-3)
		end
		
		--player
		circfill(plocx,plocy,1,9)
		--pset(plocx,plocy,9)
		
		local u,d,l,r=get_nearest(locs,msel)
		msel=btnp"0" and l or btnp"1" and r or btnp"2" and u or btnp"3" and d or msel
		rectfill(camx,camy,camx+8,camy+105,0)
		uirect(38,103,50,11)
		printd(un_spl"SYSTEM VIEW,42,106,3")
	end
end


function get_nearest(lc,m)
local u,d,l,r=m,m,m,m
local uy,dy,lx,rx=un_spl"-100,100,-100,100"
for i=1,24 do
if m!=i then
local xdiff,ydiff=lc[i].x-lc[m].x,lc[i].y-lc[m].y
if abs(xdiff)<abs(ydiff) then
	if ydiff<0 and ydiff>uy then
		uy=ydiff;u=i
	elseif ydiff>0 and ydiff<dy then
		dy=ydiff;d=i
	end
else
	if xdiff<0 and xdiff>lx then
		lx=xdiff;l=i
	elseif xdiff>0 and xdiff<rx then
		rx=xdiff;r=i
end end end end
return u,d,l,r
end

function togglezmenu()
	sfx3"37"
	zopen=not zopen
	xchoose,showmap,zmc,zchoice=f,f,1,1
end

function stretch_map()
mx=shifter(not showmap,mx,60,6)
my=mx
if (showmap) mapopen=t
end



--mapopen == showmap?
-->8
-- music

local orb_music={
		{26,0,18},{10,34},{40}
}

local _l,_loops=0,{0,0}

function orbit_music()
	if music_on then
		if stat"24"==-1 then
			local mu=mopen and 3 or pmode
			local songs=orb_music[mu]
			_l=_l>=#songs and 1 or _l+1
			music(songs[_l],2000)
		end
		if (stat"25"==10) music(-1,3600)
	else
		music"-1"
	end
end

function reset_o(o)
	local this=o==3 and 2 or o
	_loops[this]=_l
	_l=_loops[3-this]
	music(-1,3000)
end

-->8
-- save/load

function save_game()
	dset(0,1) -- save exists
	local b_artb,b_sc1,b_sc2,b_sc3=bpack(artb),{},{},{}
	for i=1,32 do
		b_sc1[i],b_sc2[i],b_sc3[i]=scans[i],scans[i+32],scans[i+64]
	end
	local x,y,vx,vy,ang=unpack(pmode==1 and {px,py,pvx,pvy,pang} or {curx,cury,curvx,curvy,curang})
	local savenums={thisrand,x,y,
					vx,vy,ang,fuel,
					b_artb,bpack(b_sc1),
					bpack(b_sc2),
					bpack(b_sc3),script}
	for _i= 1,#savenums do
		dset(_i,savenums[_i])
	end
	popup"GAME SAVED"
end

function load_game()
	thisrand,px,py,pvx,pvy,pang,fuel,artb,script=
	dget"1",dget"2",dget"3",dget"4",dget"5",
	dget"6",dget"7",bunpack(dget"8"),dget"12"
	for j=0,2 do
		local b32=bunpack(dget(9+j))
		for i=1,32 do
			scans[i+32*j]=b32[i]
		end
	end
	starhit,x_do=f,dont
end


function bpack(nums)
	local b=0
	for i =-15,#nums-16 do
		b=b|nums[i+16]>>i
	end
	return b
end

function bunpack(b)
	local t={}
	for i =-15,16 do
		local c=(b&1>>i)<<i
		t[i+16]=abs(c)
	end
	return t
end

-->8
-- utility
pops={}
actions={}
rcol={1,3,0}


function do_cos()
	if pops[1] then
		local p=pops[1]
		if (not coresume(p)) del(pops,p)
	end
	for a in all(actions) do
		if (not coresume(a)) del(actions,a)
	end 
end


function cossin(x,y,r,a)
	return x+r*cos(a),y+r*sin(a)
end


function printd(m,x,y,c)
	p_shadow(m,camx+x,camy+y,c)
end


function p_shadow(m,x,y,c)
	?m,x+1,y+1,1
	?m,x,y,c
end


function uirect(x,y,w,h)
	for _g=1,3 do
		rectfill(camx+x+_g,camy+y+_g,camx+x+w-_g,camy+y+h-_g,rcol[_g])
	end
end


function shifter(bool,val,amt,speed)
	return bool and min(amt,val+speed) or max(0,val-speed)
end


function sfx3(fx) 
	sfx(fx,3)
end


function dont() end


function un_spl(...)
	return unpack(split(...))
end

-->8
-- artifact scripts --
a1,a2=0,.125


scripts=split("(sTRANGE FLOWING SYMBOLS\nAPPEAR IN YOUR VISUAL\nDISPLAY. tHEY DO NOT MATCH\nANY KNOWN FORM OF WRITTEN\nLANGUAGE.):\n\n      ...ANALYZING...:\n\n   ...ANALYSIS FAILED...::(YOUR LINGUISTIC CODEX HAS\nBEEN UPDATED BY AN OUTSIDE\nSOURCE...):\n\n     ...TRANSLATING...:\"wE ARE PART OF A KEY\n  AND PART OF A DOOR.\n\n wE SEEK THE OTHER,\n  AND AWAIT THE SEEKER.\":(iT SEEMS THERE IS, OR WAS\nINTELLIGENT LIFE HERE.\ni MUST FIND MORE CLUES.);\n\n     ...TRANSLATING...:\"tHERE IS MORE TO BE FOUND,\n  WHEN WE LEARN TO SEE.\n\n wHAT ONCE WAS LOCKED,\n  SHALL BE OPENED.\":(oUR ENGINE SYSTEMS HAVE\n BEEN ALTERED, ALLOWING FOR\n MORE EFFICIENCY.);\n\n     ...TRANSLATING...:\"tHEIR PATH IS LAID\n  BEFORE THEM.\n\n oUR MEMORIES ARE\n  YOUR OWN.\":(oUR STARMAP HAS BEEN\n  UPDATED);\n\n     ...TRANSLATING...:\"tHE WAY WILL OPEN AND SHUT,\n\n  IN THE SPACE BETWEEN.\":(oUR ENGINE SEEMS TO HAVE A\nNEW FUNCTION. iT TRANSLATES\n AS \"sLIP tUNNEL\".);\n\n     ...TRANSLATING...:\"wE ARE THE FIRST.\n  aRE WE THE LAST?\n\n wE YEARN FOR THE OTHER.\":(wHO/WHAT IS THIS \"OTHER\"?\n wAS THE GALAXY DEVOID OF\n OTHER LIFE? iS IT STILL?);\n\n     ...TRANSLATING...:\"wE NO LONGER NEED,\n  YET WE SEEK, STILL.\n\n  wE WISH TO SHARE\n  WITH THE OTHER.\":(eNERGY COURSES THROUGH OUR\n SYSTEMS, FROM WHAT SOURCE,\n WE DO NOT KNOW.);\n\n     ...TRANSLATING...:\"tHIS SPACE IS EMPTY,\n  BUT WE BELIEVE THE SEEKER\n  WILL COME.\n\n sEEK, AND WE SHALL OPEN\n  THE WAY WE HAVE GONE.\":(iS IT POSSIBLE THEY ARE\n STILL ALIVE SOMEWHERE?);\n\n     ...TRANSLATING...:\"tHE KEY IS COMPLETED,\n  SEEK NOW THE DOOR.\n\n fOLLOW IN OUR PATH,\n  SEEKERS NO MORE.\":(a NEW BLIP HAS APPEARED ON\n MY STAR MAP. tHAT MUST BE\n THIS \"DOOR\".\n tIME TO GO THROUGH.",";",false)


function read_script(n)
	if (script==3) then
		for i=1,96 do 
			scans[i]=1 
		end
	end
	reset_o(3)
	artb[cstar]=1
	drawhud=f
	local lifted=f
	local c=cocreate(
	function()
		local _s=split(scripts[n],":",f)
		for x=1,30 do
 	 yield()
 	end
		mopen=t
		z_do=dont
		local _i,_x,old_x_do=0,4,x_do
		x_do=(function() 
		_i+=1
		if(script==1 and _i==4) popup("iNCOMING TRANSMISSION") 
		end)
		while _x>0 do
			uirect(64-_x,76,_x*2-1,48)
			_x=shifter(_i<=#_s,_x,60,4)
			if _x==60 then
				if _i==0 then
				 alien_script(n)
				else
					printd(_s[_i],10,82,3)
				end
			end
			fuel=min(maxfuel,fuel+1)
			yield()
		end
		local _t=time()
		while not lifted do
			local dt=(time()-_t)/4
			arty-=dt*dt
			if (arty<-200) lifted=t
			yield()
		end
		x_do,z_do,mopen,artp[cstar]=old_x_do,togglezmenu,f,0
		script+=1
		save_game()
	end)
	add(actions,c)
end


function alien_script(num)
	srand(num)
	local lines=num<9 and ceil(rnd"4") or 1
	a1+=.0030
	a2+=.0012
	for _i=1,lines do
		local lets=num<9 and 8+ceil(rnd"8") or 3
		for _j=1,lets do
			local _a,_sx,_sy,x,y=1-rnd"2",rnd"10",rnd"6",camx-hide_hud+23+_j*7,camy+2-hide_hud*.8
			if num<9 then
				x,y=camx+10+6*_j,camy+80+7*_i
			end
			sspr(10+_sx*cos(a1*_a),38+_sy*cos(a2*_a),5,5,x,y)
		end
	end
	srand((px+py)*.03125)
end

__gfx__
000000000110000000000000000110000000000000100000000000000000000000000100000aaaaaaaaaaa000aaaaaaaaaaa0000000000000000000000000000
000000001cc1000000010000001cc3000000011001c10000000000000000000000011161000aaaaaaaaa0001000aaaaaaaaa0000000000000000000000000000
000000001c6c1000001c110001cc310000001cc001c10000000000000000000001113166610aaaaaaa00011161000aaaaaaa0000000000000000000000000000
00007000cccc1000001cc31001ccc1000011cc3001cc1000000000000000000010011166111aaaaa000111316661000aaaaa0000000000000000000000000000
000007001cc310000001cc101cc6c10001ccccc0011c3100000000000000000001100111d10aaa0001100111661111000aaa0000000000000000000000000000
000070001c31000000001c101ccc310001cc3310001cc1000000000000000000011310d3d10a00011111100111db7761000a0000000000000000000000000000
00000000131000000000010001cc3100001110000001c1000000000000000000001131d31000011131111310d3d7b16661000000000000000000000000000000
00000000010000000000000000133000000000000000100000000000000000000013113d1000100111111131d3100d6611100000000000000000000000000000
0033330000033330000000000bb0bb00000b00000000000000000000000000000001313100000110011113113ddddd11d1000000000000000000000000000000
033330000000333300000000b00000b0000b0000000000000000000000000000000115d1000a0113100111313dd000d3d10a0000000000000000000000000000
330000000000000330000000b00000b00000000000000000000000000000000000001d10000a001131100115d100ddd3100a0000000000000000000000000000
33000000000000033000000000000000bb000bb000000000000000000000000000001d10000aa0131111100610dddbbd10aa0000000000000000000000000000
330000000000000330000000b00000b00000000000000000000000000000000000000d00000aa00131111116dddddd3100aa0000000000000000000000000000
300000000000000030000000b00000b0000b000000000000000000000000000000000000000aaa011b111116ddbdd5d10aaa0000000000000000000000000000
0000000000000000000000000bb0bb00000b000000000000000000000000000000000000000aaa0010011116ddbdd1100aaa0000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000aaaa01d100116ddb11d10aaaa0000000000000000000000000000
000000000000000000000000101000000000000000000000000000000000000000000000000aaaa0015110010bddd100aaaa0000000000000000000000000000
000000000000000000000000030000000000000000000000000000000000000000000000000aaaaa01355116d1ddd10aaaaa0000000000000000000000000000
000000000000000000000000101000000000000000000000000000000000000000000000000aaaaa00115136d661100aaaaa0000000000000000000000000000
300000000000000030000000000000000000000000000000000000000000000000000000000aaaaaa01001116d1110aaaaaa0000000000000000000000000000
330000000000000330000000000000000000000000000000000000000000000000000000000aaaaaa001100111d100aaaaaa0000000000000000000000000000
330000000000000330000000000000000000000000000000000000000000000000000000000aaaaaaa015316d3d10aaaaaaa0000000000000000000000000000
330000000000000330000000000000000000000000000000000000000000000000000000000aaaaaaa001131d3100aaaaaaa0000000000000000000000000000
033330000000333300000000000000000000000000000000000000000000000000000000000aaaaaaaa013113d10aaaaaaaa0000000000000000000000000000
003333000003333000000000000000000000000000000000000000000000000000000000000aaaaaaaa001313100aaaaaaaa0000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaa0115d10aaaaaaaaa0000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaa001d100aaaaaaaaa0000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaa01d10aaaaaaaaaa0000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaa00d00aaaaaaaaaa0000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaa010aaaaaaaaaaa0000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaa000aaaaaaaaaaa0000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00300303333030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03000b30000330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00003030000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03011131103300330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00130030010000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01000300001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
100b3000000100300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1103000000013b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01000000001003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100330010330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00311001133000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000017100000000000000001710000000100000000000000000000000000010000000000000000000000000000d0000000000000000007000000
00000000000000001710000000000000000171000000171000000000000000000000000017100000000000000000000000000ddd000000000000000077700000
0000000000000000171000000000000000001000000017100000000000000000000000017100000000000000000000000000ddddd00000000000000777770000
000000000000000171000000000000000000000000001710000000000000000000000001710000000000000000000000000ddd1ddd0000000000007776777000
00000000000000017100000000000000000000000001710001111000000000000000000171000000000000000000000000dd11011dd000000000077660667700
0000100001110001710011100000000000100000011171111177710011110000100000171000000000000000000000000d110000011d00000000766000006670
00017101177710017111777110000000017100011777777777111011777711017100001710000000000000000000000011000000000110000006600000000066
00017117711100017177111771000000017100177111711111000177111177117100001710000000000000000000000000000000000000000000000000000000
00017171100000171711000117100000017100011017100000001711000011771000001710000000000000000000000000000000000000000000000000000000
000177100000001771000000171000001710000000171000000171000000001710000171000000000000000000000000001dddd1100000000000067777660000
00177100000000171000000001710000171000000017100000017100000000171000017100000000000000000000000001ddddddd10000000000677777776000
0017100000000017100000000171000017100000001710000017100000000017100001710000000000000000000000001ddddddddd1000000006777777777600
001710000000001710000000017100001710000000171000001710000000001710000171000000000000000000000001ddd001dddd1000000067770067777600
001710000000017100000000017100017100000001710000017100000000017100001710000000000000000000000001dd0000dddd1000000077700007777600
00171000000001710000000001710001710000000171000001710000000001710000171000000000000000000000001dd00000dddd1000000677000007777600
00171000000001710000000017100001710000000171000001710000000001710000171000000000000000000000001d100001dddd0000000676000067777000
00171000000001710000000017100001710000000171000001710000000001710000171000000000000000000000000000000ddddd0000000000000077777000
01710000000001710000000177100017100000001710000000171000000011710001710000000000000000000000000000000dddd10000000000000077776000
01710000000017171000001171000017100110001710011000171000001177100001710011000000000000000000000000000dddd10000000000000077776000
01710000000017117111117710000017111771001711177100017111117717171001711177100000000000000000000000001dddd00000000000000677770000
0171000000001710177777710000000177711000017771100000177777110171000017771100000000000000000000000000ddddd00000000000000777770000
0010000000000100011111100000000011100000001110000000011111000010000001110000000000000000000000000000dddd100000000000000777760000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dddd000000000000000777700000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001dddd000000000000006777700000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001d10000dddd1000000067600007777600000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001ddd1001dddd0000000677760067777000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddd00dddd10000000777770077776000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dddd101dddd00000000777760677770000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001dd101ddd1000000000677606777600000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001dddddd10000000000067777776000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001dd1000000000000000677600000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000k00
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006k0000000000000000h0000
00000000000000t0000000000000000000000000000000000000000000000000000000000000000000000000000000000h000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000
0000000000000000h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000h0000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000007000000000000000000000000000000h00000000000000000000000007000000000000000000000000000000000000000000
000h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000h0000000h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000h000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000h00000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000h0h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000h000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000h00
h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000h000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000h0h0h000hh000000000000000000000000000000000000000000s
0000000000000000000000000000000000000000000000000000000000000000000000t0h00h0h0h000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000hhhh00h0h00h000hh000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000h000000000000000t0thh0000000000hh00h0h00h00000000000000000000000000000000000000000
0000000000000000000000000000000000h00000000000000000000000700th0h000000h00000h0h000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000th000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000t0000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000t00000000000000000000000000h0000000000000000000h0000000000000000000000000000
00000000000000000000000000000000000000000000000006t00000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000h000000000000000000000000000066600000000000000000000h00000000000000000000000000000000000h00000000000000000000
0000000000000000000000000000000000000000000000000600000000h00000000000000000000000000000000000000000000000000000000000000h000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000
000000000000000000000000ppppppp0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000ppaaaaaaapp00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000ppaaaaaaaaaaapp000000000000000000000000h00000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000ppaaaaaaaaaaaaapp0000000000000000000000h7h0000000000000000h7h0000000h0000000000000000000000000h0h000000000000
000000000000000000paaaaaaaaaaaaaaaaap000000000000000000000h7h0000000000000h00h7h000000h7h0000000000000000000000000h7h00000000000
00000000000000000ppaaaaaaaaaaaaaaaaapp00000000000000000000h7h00000000000000000h0000000h7h000000000000000000000000h7h000000000000
00000000000000000paaaaaaaaaaaaaaaaaaap0000000000000000000h7h00000000000000000000000000h7h000000000000000000000000h7h000000000000
0000000000000000paaaaaaaaaaaaaaaaaaaaap000000000000000000h7h0000000000000000000000000h7h000hhhh000000000000000000h7h000000000000
0000000000000h00paaaaaaaaaaaaaaaaaaaaap0000000h0000hhh000h7h00hhh00000000000h000000hhh7hhhhh777h00hhhh0000h00000h7h0000000000000
000000000000000paaaaaaaaaaaaaaaaaaaaaaap00000h7h0hh777h00h7hhh777hh00000000h7h000hh777777777hhh0hh7777hh0h7h0000h7h0000000000000
000000000000000paaaaaaaaaaaaaaaaaaaaaaap00000h7hh77hhh000h7h77hhh77h0000000h7h00h77hhh7hhhhh000h77hhhh77hh7h0000h7h0000000000000
000000000000000paaaaaaaaaaaaaaaaaaaaaaap00000h7h7hh00000h7h7hh000hh7h000000h7h000hh0h7h0000000h7hh0000hh77h00000h7h0000000000000
00000h000000000paaaaaaaaaaaaaaaaaaaaaaap00000h77h0000000h77h000000h7h00000h7h0000000h7h000000h7h00000000h7h0000h7h00000000000000
000700000000000paaaaaaaaaaaaaaaaaaaaaaap00h0h77h00000000h7h00000000h7h0000h7h0000000h7h000000h7h00000000h7h0000h7h00000000000000
000000000000000paaaaaaaaaaaaaaaaaaaaaaap0000h7h000000000h7h00000000h7h0000h7h0000000h7h00000h7h000000000h7h0000h7h00000000000000
000000000000000paaaaaaaaaaaaaaaaaaaaaaap0000h7h000000000h7h00000000h7h0000h7h0000000h7h00000h7h000000000h7h0000h7h00000000000000
0000000000000000paaaaaaaaaaaaaaaaaaaaap00000h7h00000000h7h000000000h7h000h7h0000000h7h00000h7h000000000h7h0000h7h000000000000000
0000000000000000paaaaaaaaaaaaaaaaaaaaap00000h7h00000000h7h000000000h7h000h7h0000000h7h00000h7h000000000h7h000th7h000000000000000
00000000000000000paaaaaaaaaaaaaaaaaaap000000h7h00000000h7h00000000h7h0000h7h0000000h7h00000h7h000000000h7h0000h7h000000000000000
00000000000000000ppaaaaaaaaaaaaaaaaapp000000h7h00000000h7h00000000h7h0000h7h000h000h7h00000h7h000000000h7h0000h7h000000000000000
000000000000000000paaaaaaaaaaaaaaaaap000000h7h000000000h7h0000000h77h000h7h0000000h7h0000000h7h0000000hh7h000h7h0000000000000000
0000000000000000000ppaaaaaaaaaaaaapp0000000h7h00000000h7h7h00000hh7h0000h7h00hh000h7h00hh000h7h00000hh77h0000h7h00hh000000000000
00000000000000000000ppaaaaaaaaaaapp00000000h7h00000000h7hh7hhhhh77h00000h7hhh77h00h7hhh77h000h7hhhhh77h7h7h00h7hhh77h00000000000
0000000000000000000000ppaaaaaaapp0000000000h7h000000h0h7h0h777777h0000000h777hh0000h777hh00000h77777hh0h7h0000h777hh000000000000
000000000000000000000000ppppppp0000000000000h000000h000h000hhhhhh000000000hhh0000000hhh00000000hhhhh0000h000000hhhs0000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000070000000000060000000000000000000000000000h0000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000s000000000000000000000000000000000000000000
00h0h000000000000000000000000000000000000000000000000000000000000000h00000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000t0000000000000000000000000000000000000h0000000000000000000000000
0000000000000000000000000000000000000000000000h000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000t0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000h0000000h0000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000h0000000000000000000000000000000000000
00000000000000000h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000h00000000000
0000000000000000000000000000000000000000000000000000000000h00000000000000000000000000000000000000000000000h000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
h00000000000000000000000000000h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000h00000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000h00000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000h000000007000000000000000
000000000000000000000000000000000000000000000h000000000000000000000000000000000000000000000000000000000000000000000000000000000h
000000000000000000000000000000000000000000000000000h0000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000s00000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000h00000000000000000000000000000
00000000000000000000000000000000000000000000000000000k00000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000h0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000h000000000s0000000000000000000000000000000000000000
000000000000000s0000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000k000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000k000000000000000000000000000
0h0000h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011400010017000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
310302001815524155000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
910c01000e07300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011003000000000000000000000000000000000000019050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010301000866518e0018e0018e000c00018e0018e000c00030d0018e000c0000ce000060018e0018e000ce000c00018e0018e0018e000c00018e0018e000c00018e0018e000c00018e00006000ce0018e000ce00
591404002c66500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100300000000000000000000000000000000000001a050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100300000000000000000000000000000000000001a050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400200d8700d8610d8510d8410d8310d8610d8710d8510d8410d8210d8110d8010110001100011000100001100011000110001105011050110501105011050110501105011050110501105000000000000000
011400201087010841108311082110831108411086110831108211083110841108611083110821108111080112870128411283112821128311284112861128311282112821128111280100000000000000000000
010a00200e073000000000018e0018c3018e000c053000000c0000ce003061518e0018c200ce0000000000000000000000000000000018c302100021d3115d11000000000014c300000018c20000000000000000
010a002010073000000000018e0015d3015d110e053000000c0000ce003061518e0018c500ce000cc10000000000000000000000000018d3021d0021d3115d1100000000000e0730000018c50000000cc1000000
010a001814c000000012c000000018c4000000000000000012c000000012c100000018c4000000000000000012c1000000000000000018c400000021d0015d0012c000000012c100000018c40000000000000000
311400181450000000000000000000000199350000000000179351c93500000199350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
311400180000019955209552093520925209151e9551c9551c915179151995519915199150d935000000193500000000000000000000000000000000000000000000000000000000000000000000000000000000
d51400200d5250b5250d5250b525085250b525085250b5250d5250b5250d52506525085250b525085250b5250d5250b5250d5250b525085250b525085250b5250d5250b5250d5250b525085250b525085250b525
8d14001c0d5250b5250d52506525085250b525085250b5250852506525045250d525015250f5250852504525145250d525065250b525045250652501525085250d52501525045250852500000000000000000000
011a002018a70000000062318a7512c500e0110c0110901116a000ce000061518a7018c500ce00000000000018a70000000062518a7018c502100021d3118a73000000ca400061510a5018c500000016c2507c10
011a00201aa7300000006251aa7512c400e00021d410900007c100ce000061517a5318c400ce0007c20000001aa73000000062518a0018c402100021d411aa6307c1013a53006150ea5318c400000007c2000000
010d002015c350000005c150000021c350000005c1504c001cd2502d0005c1502c0021c350000005c151cd1515c4502c1105c1102c1121c350000005c150000015d250000005c150000021c3502c1505c1000000
111a00201285212842128320e8520e8420e8320e8220e8320e8420e8520e8420e8320e8220e8520e842128621285212842128320b8500b8400b8300b8200b8300b8400b8500b8400b8300b8200b8200b8100b810
811a0020197461573619726197461573619726157161572615736157461573615726157161474614736147561274612736127260b7460b7360b726127160b7260b7360b7460b7360b7260b7160b7160b7160b716
811a002019746157361972619746197361972617716127261573615746157361572615716197461c736147561e74619736127260b7460b7361972612716127260b7360b7460b7360b7260b7160b7160b7160b716
050a00200cc700cc000cc200cc000cc7018e000cc30146550cc700cc000cc100cc200cc7000c000cc1000c000cc700cc200cc200cc000cc7018e000cc201ec500cc700cc000cc200cc000cc7000c000cc1000c00
051400180127501105021750310001075011050227501105011750110504075011050110501105002750110501175011050107501105011050110501105011050110501105011050110501105011050110501105
0d14001800000155550000012555000000d565000000b565000001054517700125211256506565000000000000000065650000000000067000670000000000000000000000000000000001700000000000000000
010a00201307318c3018c4018c101005318e0018c401106318d4018d21100530cc303961518c1018c200cc401307318c1018c3018c201005318e0018c30110630cc700cc101005318c40396150cc5018c400cc30
010a00180e07318e0018c40006000c05318e0018d5018d3118d0018d000c0530ce003061518e0018c400ce000e07318e0018c400060018d4018d4118c4018e0005600006000c00018e00006000ce0018e000ce00
ada0002001054010510105101055030540305103051030550d0540d0510d0510d055160441404114041140450d0540d0510d0510d055060540605106051060550a0340a0310a0310a03503054060510605106055
65a0002006044060410604106045080340a0310a0210a025080440804108041080450f0340f0310f0210f025080440804108041080450d0340a0310a0210a0250d0340d0310d0310d0350a034080410804108045
010a00201307318c0018c1018c0018c6018c001106318c100cc7018c000cc200cc003961518c0018c200cc000cc7018c1018c2018c001005318c0018c300cc000cc700cc001005318c10396150cc3018c100cc00
010a0020197151b7151e7152071512715197151b72519715197251b715127341273519715197341b71519725197251b7151e7152071512715197251b72519715197151b725127251472519725197341b73519725
010a0020197151b7151e7002070012715197001b725197151970012734127350000019715127441272106001197251b7001e7152070012715197251b700127151671016711197211971119711160010000000000
0118002019a7019c0019c300000025d35030000300025c300d00019c300d0000000025c30140001400025c4019c301cc4019a701800025d350f0000f00025c300a00019c300a0000000025c40060000600025c30
8530002012854128511285112855148541485114851148550f8540f8510f8510f8550f8540f8510f8510f85512854128511285112855118541185111851118550f8540f8510f8510f8550f8540f8510f8510f855
cf030000000000c6310d6310e6310f63110631116311263113631146311563116631176311c631106210563105631026310263102631066300763000000000000000000000000000000000000000000000000000
310200001d0301d0201d0101d0101d0101d0101d0101d0001d0001d0001d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007000026010210250000000000000001d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600000064526615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
391818002371223712237122371223712237122371223712237122371223712237122371223712237122371223712237122371223712237122371223712237150000000000000000000000000000000000000000
010100001e7501e7301e7201e71000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
935304001a6341a6411a6311a63500600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000000000000
0306002024d150000018d15000003cd350000018d150000024d150000018d15000003cd350000030d00000003cd0000000000000000030d000000000000000003cd0000000000000000030d00000000000000000
c53000200d5220d5220d5220d5220d5220d5220d5220d5220d5220d5220d5220d5220d5220d5220d5220d5220d5220d5220d5220d5220d5220d5220d5220d5220d5220d5220d5220d5220d5220a5220a5220a522
031a002021d0019c1512c000e00021d4121d0025c150ce020060019c1518c000e00021d41090000dc00000000060019c1518c000e00021d410900025c1513a000060019c1518c000e00021d410900025c0000000
412a00201983019820198101583015820158101581015820158201583015820158101581015830158201983019820198101981012830128201281012810128101282012830128201281012810128101281012810
412a00201983019821198111a8311a8211a8111a8111a8211a8211a8311a8211a8111a81119831198211e8312082120811208111e8311e8211e8111b811178111782117831178211781117811178111781117811
492000200d8450d8400d8310d8210d8110d8110d801010000d8450d8400d8310d8210d8110d8110d8010300003000030000300001000010000100001000000000000001000010000600006000010000100000000
490f002017a700000017a700d0000d6410d6210d60119c3024c2001c00000000f3001bc300d0000d6000d60024c200000017a70000001bc300d0000d6310d60124c200000000000000001bc30000000000000000
41f00c000c8340c8610c8310c8010c8310c8610c8310c8010d8310d8610d8310c8010c8340c8610c8310c80100000000000000000000000000000000000000000000000000000000000000000000000000000000
41f00c001882418841188211780116821168411682115801148211484114821168010c8240c8410c8210c80100000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
014e00000000000000000000000000000180000000004700067000000000000000000000000000000000000000000129001290010900000000000000000000000000000000000000000000000000000000000000
932800003460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033600
013c0000197001b7001e7002070012700197001b70019700197001b700127001270019700197001b70019700197001b7001e7002070012700197001b70019700197001b700127001470019700197001b70019700
005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 0a084d3d
00 0a080d3d
00 4a090d7d
00 0b080e3d
00 0b080e3d
00 0a080f3d
00 0a08103d
00 0c08103d
00 4a090f7d
02 0a08103d
00 5411533c
00 5411133c
01 1412133c
00 1415133c
00 14161312
00 14161312
00 12165352
02 1412133c
00 173e6855
01 1718573e
00 1718193e
00 1a18573e
00 1a18193e
00 1b18193e
00 1b19573e
02 1856583e
01 1c535455
00 1c1d5455
01 171c1d54
00 1d1c1e55
00 1f691e3f
00 1c1e1f7f
02 1c1d207f
00 41424344
01 2142223b
00 212a223b
02 212a222b
01 146e6d3c
03 542e2d7c
03 2f303144
01 31327042
03 31323042

