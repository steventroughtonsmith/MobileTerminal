//
//  main.m
//  FindEntryPointOfImage
//
//  Created by Steven Troughton-Smith on 08/10/2016.
//  Copyright © 2016 High Caffeine Content. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <mach-o/loader.h>
#import <mach-o/dyld.h>
#import <mach-o/arch.h>
#import <dlfcn.h>

int findEntryPointOfImage(char *path, int argc, char **argv)
{
	void *handle;
	int (*binary_main)(int binary_argc, char **binary_argv);
	char *error;
	int err = 0;
	
	printf("Loading %s…\n", path);
	
	handle = dlopen (path, RTLD_LAZY);
	if (!handle) {
		fputs (dlerror(), stderr);
		err = 1;
	}
	
	uint64_t entryoff = 0;
	
	/* Find LC_MAIN, entryoff */
	
	uint32_t count = _dyld_image_count();
	
	BOOL didFind = NO;
	
	for(uint32_t i = 0; i < count; i++)
	{
		//Name of image (includes full path)
		const char *dyld = _dyld_get_image_name(i);
		
		if (strcmp(dyld, path) == 0)
		{
			didFind = YES;
			const struct mach_header *header = (struct mach_header *)_dyld_get_image_header(i);
			
			if (header->magic == MH_MAGIC_64)
			{
				printf("MH_MAGIC_64\n");
				const struct mach_header_64 *header64 = (struct mach_header_64 *)_dyld_get_image_header(i);
				
				uint8_t *imageHeaderPtr = (uint8_t*)header64;
				typedef struct load_command load_command;
				
				imageHeaderPtr += sizeof(struct mach_header_64);
				load_command *command = (load_command*)imageHeaderPtr;
				
				for(int i = 0; i < header->ncmds > 0; ++i)
				{
					if(command->cmd == LC_MAIN)
					{
						struct entry_point_command ucmd = *(struct entry_point_command*)imageHeaderPtr;
						
						entryoff = ucmd.entryoff;
						printf("LC_MAIN EntryPoint offset: 0x%llX\n", entryoff);
						didFind = YES;
						break;
					}
					
					imageHeaderPtr += command->cmdsize;
					command = (load_command*)imageHeaderPtr;
				}
			}
			else
			{
				printf("MH_MAGIC\n");
				
				const struct mach_header *header = (struct mach_header *)_dyld_get_image_header(i);
				
				uint8_t *imageHeaderPtr = (uint8_t*)header;
				typedef struct load_command load_command;
				
				imageHeaderPtr += sizeof(struct mach_header);
				load_command *command = (load_command*)imageHeaderPtr;
				
				for(int i = 0; i < header->ncmds > 0; ++i)
				{
					if(command->cmd == LC_MAIN)
					{
						struct entry_point_command ucmd = *(struct entry_point_command*)imageHeaderPtr;
						
						entryoff = ucmd.entryoff;
						printf("LC_MAIN EntryPoint offset: 0x%llX\n", entryoff);
						
						didFind = YES;
						break;
					}
					
					imageHeaderPtr += command->cmdsize;
					command = (load_command*)imageHeaderPtr;
				}
			}
			
			printf("Found %s\n",  dyld);
			
			if (didFind)
			{
				break;
			}
		}
	}
	
	int returnCode = -1;
	
	if (didFind)
	{
		binary_main = dlsym(handle, "_mh_execute_header")+entryoff;
		if ((error = dlerror()) != NULL)  {
			fputs(error, stderr);
			err = 1;
		}
		
		if (err == 0)
		{
			setprogname([[NSString stringWithUTF8String:path].lastPathComponent UTF8String]);
			
			//returnCode = (*binary_main)(argc, argv);
			//printf ("exit(%i)\n", (*binary_main)(argc, argv));
			dlclose(handle);
		}
	}
	else
	{
		//printf("\nDidn't find image to load.\n\n");
	}
	
	return returnCode;
}


int main(int argc, const char * argv[]) {
	@autoreleasepool {
		findEntryPointOfImage("/Developer/usr/bin/iprofiler",0,"");
	}
    return 0;
}
