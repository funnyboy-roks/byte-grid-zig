render: render.zig stb_image_write.o
	zig build-exe -femit-bin=$@ -I. $^ -lc

stb_image_write.o: stb_image_write.h
	gcc -c -x c -o $@ -DSTB_IMAGE_WRITE_IMPLEMENTATION $^
