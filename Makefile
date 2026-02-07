render: render.zig stb_image_write.o
	zig build-exe -femit-bin=$@ -I. $^ -lc

stb_image_write.o: stb_image_write.h
	gcc -c -x c -o $@ -DSTB_IMAGE_WRITE_IMPLEMENTATION $^

stb_image_write.h:
	wget https://github.com/nothings/stb/raw/refs/heads/master/stb_image_write.h
