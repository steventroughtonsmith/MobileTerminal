//
//  Interpose.m
//  MobileTerminal
//
//  Created by Steven Troughton-Smith on 23/03/2016.
//  Copyright © 2016 High Caffeine Content. All rights reserved.
//

#import <Foundation/Foundation.h>


#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <pthread.h>
#include <dlfcn.h>
#import <mach-o/loader.h>
#import <mach-o/dyld.h>
#import <mach-o/arch.h>

int MT_PID = 0;

int callEntryPointOfImage(char *path, int argc, char **argv)
{
	void *handle;
	int (*binary_main)(int binary_argc, char **binary_argv);
	char *error;
	int err = 0;
	
//	printf("Loading %s…\n", path);
	
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
//				printf("MH_MAGIC_64\n");
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
//						printf("LC_MAIN EntryPoint offset: 0x%llX\n", entryoff);
						didFind = YES;
						break;
					}
					
					imageHeaderPtr += command->cmdsize;
					command = (load_command*)imageHeaderPtr;
				}
			}
			else
			{
//				printf("MH_MAGIC\n");
				
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
//						printf("LC_MAIN EntryPoint offset: 0x%llX\n", entryoff);
						
						didFind = YES;
						break;
					}
					
					imageHeaderPtr += command->cmdsize;
					command = (load_command*)imageHeaderPtr;
				}
			}
			
//			printf("Found %s\n",  dyld);
			
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
			
			returnCode = (*binary_main)(argc, argv);
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


typedef struct interpose_s { void *new_func;
	void *orig_func; } interpose_t;

//extern void UIApplicationInstantiateSingleton(Class c);

void my_exit(int size);
pid_t my_fork();
pid_t my_getpid();
int my_execve(const char *path, char *const argv[]);

//void my_UIApplicationInstantiateSingleton(Class c);

static const interpose_t interposing_functions[] \
__attribute__ ((used, section("__DATA, __interpose"))) = {
	
 { (void *)my_exit, (void *)exit},
	{ (pid_t *)my_fork, (void *)fork},
	{ (pid_t *)my_getpid, (void *)getpid},

	{ (int *)my_execve, (void *)execv},
	{ (int *)my_execve, (void *)execvp}

//(void *) my_UIApplicationInstantiateSingleton, (void *)UIApplicationInstantiateSingleton

};

pid_t my_getpid()
{
	return MT_PID;
}

pid_t my_fork ()
{
	MT_PID++;
	printf("fork() -> %i\n",MT_PID);
	return MT_PID;
}

int my_execve(const char *path, char *const argv[])
{
	int args = 0;
	
	while (argv[args] != 0)
		args++;
	
	return callEntryPointOfImage((char *)path, args, (char **)argv);
}


void my_exit (int errcode)
{
	if (errcode == SIGTERM)
	{
	
		
		//printf("Exited %i.\n", errcode);
	}
	fflush(stdout);
	fflush(stderr);
	pthread_exit(NULL);
}
//
//void my_UIApplicationInstantiateSingleton (Class C)
//{
//	printf("UIApplicationInstantiateSingleton()\n");
//}