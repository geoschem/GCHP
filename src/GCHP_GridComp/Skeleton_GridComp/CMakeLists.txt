# Skeleton_GridComp/CMakeLists.txt

add_library(Skeleton_GridComp STATIC
	Skeleton_GridCompMod.F90
)
target_link_libraries(Skeleton_GridComp PUBLIC GeosCore)
