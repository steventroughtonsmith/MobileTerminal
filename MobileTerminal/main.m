//
//  main.m
//  MobileTerminal
//
//  Created by Steven Troughton-Smith on 23/03/2016.
//  Copyright © 2016 High Caffeine Content. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#include <dlfcn.h>
#import <mach-o/loader.h>
#import <mach-o/dyld.h>
#import <mach-o/arch.h>

#define printf //

void findMachHeader64();

int64_t __internal_vmaddr_min = -1;
uint64_t __internal_data_vmaddr = 0;
uint64_t __internal_data_vmsize = 0;
uint64_t *__internal_data_backupaddr;
uint8_t *imageHeaderPtr;

void MTBackupDataSegment()
{
	return;
	__internal_data_backupaddr = (uint64_t *)malloc(__internal_data_vmsize);
	
	//	if (__internal_vmaddr_min <= 0)
	//	{
	//		findMachHeader64();
	//	}
	
	//	printf("__internal_data_vmaddr: %llu\n", __internal_data_vmaddr);
	//	printf("__internal_data_vmsize: %llu\n", __internal_data_vmsize);
	//	printf("__internal_data_backupaddr: %llu\n", __internal_data_backupaddr);
	//	printf("__internal_vmaddr_min: %llu\n", __internal_vmaddr_min);
	
	printf("memcpy( %llX, %llX, %llX)\n\n", __internal_data_backupaddr, (__internal_data_vmaddr-__internal_vmaddr_min + imageHeaderPtr), __internal_data_vmsize);
	memcpy(__internal_data_backupaddr, (__internal_data_vmaddr-__internal_vmaddr_min + imageHeaderPtr), __internal_data_vmsize);
}

void MTRestoreDataSegment()
{
	return;
	//	printf("__internal_data_vmaddr: %llu\n", __internal_data_vmaddr);
	//	printf("__internal_data_vmsize: %llu\n", __internal_data_vmsize);
	//	printf("__internal_data_backupaddr: %llu\n", __internal_data_backupaddr);
	//	printf("__internal_vmaddr_min: %llu\n", __internal_vmaddr_min);
	
	//	if (__internal_vmaddr_min <= 0)
	//	{
	//		findMachHeader64();
	//	}
	
	printf("memcpy( %llX, %llX, %llX)\n\n", (__internal_data_vmaddr-__internal_vmaddr_min + imageHeaderPtr),__internal_data_backupaddr, __internal_data_vmsize);
	
	memcpy((__internal_data_vmaddr-__internal_vmaddr_min + imageHeaderPtr), __internal_data_backupaddr, __internal_data_vmsize);
}




void findDataSegment(const struct mach_header_64 *header)
{
	imageHeaderPtr = (uint8_t*)header;
	typedef struct load_command load_command;
	
	imageHeaderPtr += sizeof(struct mach_header_64);
	load_command *command = (load_command*)imageHeaderPtr;
	
	for(int i = 0; i < header->ncmds > 0; ++i)
	{
		if(command->cmd == LC_SEGMENT_64)
		{
			struct segment_command_64 ucmd = *(struct segment_command_64*)imageHeaderPtr;
			
			if (ucmd.vmaddr != 0 && ucmd.vmaddr < __internal_vmaddr_min)
				__internal_vmaddr_min = ucmd.vmaddr;
			
			if (strcmp(ucmd.segname, "__DATA") == 0)
			{
				printf("seg: %s\n", ucmd.segname);
				printf("lc: %i\n", i);
				printf("vmaddr: %llu\n", ucmd.vmaddr);
				printf("vmsize: %llu\n", ucmd.vmsize);
				
				__internal_data_vmaddr = ucmd.vmaddr;
				__internal_data_vmsize = ucmd.vmsize;
			}
			else
			{
				printf("seg: %s\n", ucmd.segname);
				printf("lc: %i\n", i);
				printf("vmaddr: %llu\n", ucmd.vmaddr);
				printf("vmsize: %llu\n", ucmd.vmsize);
			}
		}
		
		imageHeaderPtr += command->cmdsize;
		command = (load_command*)imageHeaderPtr;
	}
}

void findMachHeader64()
{
	//uint32_t count = _dyld_image_count();
	
	for(uint32_t i = 0; i < 1; i++)
	{
		//Name of image (includes full path)
		const char *dyld = _dyld_get_image_name(i);
		
		//Get name of file
		int slength = (int)strlen(dyld);
		
		int j;
		for(j = slength - 1; j>= 0; --j)
			if(dyld[j] == '/') break;
		
		//strndup only available in iOS 4.3
		char *name = strndup(dyld + (++j), slength - j);
		//printf("%s ", name);
		free(name);
		
		const struct mach_header_64 *header = (struct mach_header_64 *)_dyld_get_image_header(i);
		//print address range
		//printf("0x%X - ??? ", (uint32_t)header);
		
		findDataSegment(header);
		
		//print file path
		printf("%s\n",  dyld);
	}
	printf("\n");
}


int main(int argc, char * argv[]) {
#if 1
	
	@autoreleasepool {
		
		
		dlopen([[[NSBundle mainBundle] sharedFrameworksPath] stringByAppendingPathComponent:@"Interpose.framework/Interpose"].UTF8String, 2);
		
		
		//		argv[0] = "/Applications/Tips.app/Tips";
		
		
		
		//		uint32_t ptr = ((int)main)& (~0xFFF);
		
		//		while (*(uint32_t*)ptr != MH_MAGIC || *(uint32_t*)ptr != MH_MAGIC_64) ptr++;
		//		findMachHeader64();
		
		
		//		MTBackupDataSegment();
		//		MTRestoreDataSegment();
//		return 0;
		return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
	}
#endif
//	callEntryPointOfImage("/System/Library/PrivateFrameworks/PrintKit.framework/printd", argc, argv);
}




/*
 sect_cmd *find_section(sgmt_cmd *seg, const char *name)
 {
	    sect_cmd *sect, *fs = NULL;
	    uint32_t i = 0;
	    for (i = 0, sect = (sect_cmd *)((uint64_t)seg + (uint64_t)sizeof(sgmt_cmd));
          i < seg->nsects;
          i++, sect = (sect_cmd*)((uint64_t)sect + sizeof(sect_cmd)))
     {
         if (!strcmp(sect->sectname, name)) {
             fs = sect;
             break;
         }
     }
	    return fs;
 }
 
 struct load_command *find_load_command(mach_hdr *mh, uint32_t cmd)
 {
	    load_cmd *lc, *flc;
	    lc = (load_cmd *)((uint64_t)mh + sizeof(mach_hdr));
	    while ((uint64_t)lc < (uint64_t)mh + (uint64_t)mh->sizeofcmds) {
         if (lc->cmd == cmd) {
             flc = (load_cmd *)lc;
             break;
         }
         lc = (load_cmd *)((uint64_t)lc + (uint64_t)lc->cmdsize);
     }
	    return flc;
 }
 
 sgmt_cmd *find_segment(mach_hdr *mh, const char *segname)
 {
	    load_cmd *lc;
	    sgmt_cmd *s, *fs = NULL;
	    lc = (load_cmd *)((uint64_t)mh + sizeof(mach_hdr));
	    while ((uint64_t)lc < (uint64_t)mh + (uint64_t)mh->sizeofcmds) {
         if (lc->cmd == LC_SGMT) {
             s = (sgmt_cmd *)lc;
             if (!strcmp(s->segname, segname)) {
                 fs = s;
                 break;
             }
         }
         lc = (load_cmd *)((uint64_t)lc + (uint64_t)lc->cmdsize);
     }
	    return fs;
 }
 
 void* find_sym(mach_hdr *mh, const char *name) {
	    sgmt_cmd* first = (sgmt_cmd*) find_load_command(mh, LC_SGMT);
	    sgmt_cmd* linkedit = find_segment(mh, SEG_LINKEDIT);
	    struct symtab_command* symtab = (struct symtab_command*) find_load_command(mh, LC_SYMTAB);
	    vm_address_t vmaddr_slide = (vm_address_t)mh - (vm_address_t)first->vmaddr;
	    
	    char* sym_str_table = (char*) linkedit->vmaddr - linkedit->fileoff + vmaddr_slide + symtab->stroff;
	    nlist_* sym_table = (nlist_*)(linkedit->vmaddr - linkedit->fileoff + vmaddr_slide + symtab->symoff);
	    
	    for (int i = 0; i < symtab->nsyms; i++) {
         if (sym_table[i].n_value && !strcmp(name,&sym_str_table[sym_table[i].n_un.n_strx])) {
             return (void*) (uint64_t) (sym_table[i].n_value + vmaddr_slide);
         }
     }
	    return 0;
 }
 */
