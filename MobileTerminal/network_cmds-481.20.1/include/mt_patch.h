#define	SO_RECV_ANYIF	0x1104		/* unrestricted inbound processing */

#define SO_RECV_TRAFFIC_CLASS	0x1087		/* Receive traffic class (bool)*/
#define SO_TRAFFIC_CLASS	0x1086	/* Traffic service class (int) */
#define	 SO_TC_BK_SYS	100		/* lowest class */
#define	 SO_TC_BK	200
#define  SO_TC_BE	0
#define	 SO_TC_RD	300
#define	 SO_TC_OAM	400
#define	 SO_TC_AV	500
#define	 SO_TC_RV	600
#define	 SO_TC_VI	700
#define	 SO_TC_VO	800
#define	 SO_TC_CTL	900		/* highest class */
#define  SO_TC_MAX	10		/* Total # of traffic classes */
#define	IP_NO_IFT_CELLULAR	6969 /* for internal use only */

#include <uuid/uuid.h>
#include <sys/sockio.h>

#include <sys/types.h>
#include <sys/socketvar.h>
