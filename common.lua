
--AUTHOR: Isabela Hutchings
-- Project: Common.lua
-- * this projects implements the k-means cluster algorithm you 
-- * specified utilizing object oriented programming
-- * my Language Study webpage: https://github.com/cssetton/csc_372_Lua_Project.git

--Meta class 
Point = {}
function Point:new(l,r)
  self.__index = self
  return setmetatable({ x = l, y = r },self)
end
-- this is a helper function that compares coordinates together
function PointEq(p,p2)
  if p.x ~= p2.x then
    return false
  end
  if p.y ~= p2.y then
    return false
  end
  return true
  end

--this is the constructor for the cordinate class
Cluster = {}
function Cluster:new(a,b) 
  self.__index = self
  return setmetatable({length = 0, cords={},center= Point:new(a,b)
  },self)
end

--this adds a new coordinate to the cluster and increases its length
function ClusterAdd(c,o) 
  table.insert(c.cords,o)
  c.length = c.length + 1
end

--this function completely cleans out the Cords object
function ClearCords(o) 
  if o.length == 0 then
    return 
  end
  o.cords={}
  o.length = 0
end

-- these functions are helper functions that help read the file form input
-- see if the file exists
function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
function lines_from(file)
  if not file_exists(file) then return {} end
  lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

-- a helper function to split the lines of a string
function split (str, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for word in string.gmatch(str, "([^"..sep.."]+)") do
                table.insert(t, word)
        end
        return t
end
-- this function goes through a list of points and return the index of the cluster
-- the point is closest to
function closestCluster(clusters, point, len)
  local curIndx= 0
  local cur = math.huge
  for i=1, len do
    local newY = (clusters[i].center.y - point.y) 
    local newX = (clusters[i].center.x - point.x)
    local dist = (newY*newY) + (newX*newX)
    if(dist < cur) then
      curIndx = i - 0
      cur = dist
    end
  end
  return curIndx
end

-- this function checks to see if we have the same center in our array
function sameCenter(p,c,len)
  for i = 1 , len do
    if PointEq(p[i],c[i].center) == false then
      return false
    end
  end
  return true
end

--this calculates the new mean in the Cluster
function ClusterMean(c)
  sumX=0
  sumY=0
  for i =1, c.length do
    sumX = sumX + c.cords[i].x
    sumY = sumY + c.cords[i].y
  end
  c.center.x = (sumX/c.length)
  c.center.y = (sumY/c.length)
end
-- actual algorithm implementations
function getData(file)
	if file_exists(file) == false then 
		print("Error: file does not exsist")
    return nil
	end
	local lines = lines_from(file);
  local k = lines[1];
  local n = lines[2];
    
    if k > n then
      print("Error: k > n");
      return nil
    end
    --store the points in a list
    local cord = {}
    for i=3, 2+n do
      local words = split(lines[i]," ")
      table.insert(cord, Point:new(tonumber(words[1]),tonumber(words[2])))
    end
    --do the 1st iteration of clusters
    local prev={}
    local centers = {}
    local iterate=1
  for i = 1, k do
    local clust = Cluster:new(cord[i].x, cord[i].y)
    table.insert(prev,clust)
    table.insert(centers,Point:new(cord[i].x, cord[i].y))
  end
  while true do
    for i = 1, n do --file the new clusters with the cordinates
      local j = closestCluster(prev,cord[i],k)
      ClusterAdd(prev[j],cord[i])
    end
    for i = 1,k do --calculate the new mean
     ClusterMean(prev[i])
    end
    if sameCenter(centers,prev,k) == true then -- if the center is the same than we found it return!!
      return {k, iterate, centers}
    end
    centers = {}
    for i = 1, k do -- insert the new centers into the centers table and clear our clusters
      table.insert(centers, Point:new(prev[i].center.x, prev[i].center.y))
      ClearCords(prev[i])
    end
    iterate = iterate + 1
  end
end
print("Provide a file:");
local f = io.read();
local ar = getData(f);
if ar ~= nil then
  print("\nThe final centroid locations are:\n")
  for i = 1 , ar[1] do
    local s = "u(".. i ..") = (".. ar[3][i].x ..",".. ar[3][i].y ..")"
    print(s)
  end
  print()
  print(ar[2] .." iterations were required")
end