/* See LICENSE file for copyright and license details. */

/* appearance */
static const unsigned int borderpx  = 1;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char *fonts[]          = { "monospace:size=9" };

static const char col_sfg[]         = "#ffffff";
static const char col_fg[]          = "#fd6883";
static const char col_bg[]          = "#1B1B1B";

static const char *colors[][3]      = {
    /*               fg       bg      border   */
    [SchemeNorm] = { col_fg,  col_bg, col_fg  },
    [SchemeSel]  = { col_sfg, col_bg, col_sfg },
};

/* tagging */
static const char *tags[] = { "I" ,  "II",   "III", "IV", "V",  "VI",
                              "VII", "VIII", "IX",  "X" };

static const Rule rules[] = {
    /* xprop(1):
     *    WM_CLASS(STRING) = instance, class
     *    WM_NAME(STRING) = title
     */
    /* class      instance    title       tags mask     isfloating   monitor */
    { "Gimp",     NULL,       NULL,       0,            1,           -1 },
    { "Firefox",  NULL,       NULL,       1 << 8,       0,           -1 },
};

/* layout(s) */
static const float mfact     = 0.5; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */

void lstack(Monitor *m) {
    unsigned int i, n, h, mw, my, ty;
    Client *c;

    for (n = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), n++);
    if (n == 0)
        return;

    if (n > m->nmaster) {
        mw = m->nmaster ? m->ww * m->mfact : 0;
        for (i = my = ty = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), i++)
            if (i < m->nmaster) {
                h = (m->wh - my) / (MIN(n, m->nmaster) - i);
                resize(c, m->wx + mw, m->wy + my, mw - (2*c->bw), h - (2*c->bw), 0);
                if (my + HEIGHT(c) < m->wh)
                    my += HEIGHT(c);
            } else {
                h = (m->wh - ty) / (n - i);
                resize(c, m->wx, m->wy + ty, m->ww - mw - (2*c->bw), h - (2*c->bw), 0);
                if (ty + HEIGHT(c) < m->wh)
                    ty += HEIGHT(c);
            }
    } else {
        mw = m->ww;
        for (i = my = ty = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), i++) {
            h = (m->wh - my) / (MIN(n, m->nmaster) - i);
            resize(c, m->wx, m->wy + my, mw - (2*c->bw), h - (2*c->bw), 0);
            if (my + HEIGHT(c) < m->wh)
                my += HEIGHT(c);
        }
    }
}

static const Layout layouts[] = {
    /* symbol     arrange function */
    { "R",      tile },    /* first entry is default */
    { "L",      lstack },    /* first entry is default */
    { "",       NULL },    /* no layout function means floating behavior */
    { "M",      monocle },
    { NULL,     NULL }
};

void movestack(const Arg *arg) {
    Client *c = NULL, *p = NULL, *pc = NULL, *i;

    if(arg->i > 0) {
        /* find the client after selmon->sel */
        for(c = selmon->sel->next; c && (!ISVISIBLE(c) || c->isfloating); c = c->next);
        if(!c)
            for(c = selmon->clients; c && (!ISVISIBLE(c) || c->isfloating); c = c->next);

    }
    else {
        /* find the client before selmon->sel */
        for(i = selmon->clients; i != selmon->sel; i = i->next)
            if(ISVISIBLE(i) && !i->isfloating)
                c = i;
        if(!c)
            for(; i; i = i->next)
                if(ISVISIBLE(i) && !i->isfloating)
                    c = i;
    }
    /* find the client before selmon->sel and c */
    for(i = selmon->clients; i && (!p || !pc); i = i->next) {
        if(i->next == selmon->sel)
            p = i;
        if(i->next == c)
            pc = i;
    }

    /* swap c and selmon->sel selmon->clients in the selmon->clients list */
    if(c && c != selmon->sel) {
        Client *temp = selmon->sel->next==c?selmon->sel:selmon->sel->next;
        selmon->sel->next = c->next==selmon->sel?c:c->next;
        c->next = temp;

        if(p && p != c)
            p->next = c;
        if(pc && pc != selmon->sel)
            pc->next = selmon->sel;

        if(selmon->sel == selmon->clients)
            selmon->clients = c;
        else if(c == selmon->clients)
            selmon->clients = selmon->sel;

        arrange(selmon);
    }
}

void cyclelayout(const Arg *arg) {
    Layout *l;
    for(l = (Layout *)layouts; l != selmon->lt[selmon->sellt]; l++);
    if(arg->i > 0) {
        if(l->symbol && (l + 1)->symbol)
            setlayout(&((Arg) { .v = (l + 1) }));
        else
            setlayout(&((Arg) { .v = layouts }));
    } else {
        if(l != layouts && (l - 1)->symbol)
            setlayout(&((Arg) { .v = (l - 1) }));
        else
            setlayout(&((Arg) { .v = &layouts[LENGTH(layouts) - 2] }));
    }
}

void togglefullscr(const Arg *arg) {
  if(selmon->sel) setfullscreen(selmon->sel, !selmon->sel->isfullscreen);
}

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
    { MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
    { MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", NULL };
static const char *termcmd[]  = { "alacritty", NULL };
static const char *vol_up[]   = { "pulsemixer", "--change-volume", "+10", NULL };
static const char *vol_down[] = { "pulsemixer", "--change-volume", "-10", NULL };
static const char *vol_mute[] = { "pulsemixer", "--toggle-mute",          NULL };

static Key keys[] = {
    /* modifier                     key        function        argument */
    { MODKEY,                       XK_a,      spawn,          {.v = dmenucmd } },
    { MODKEY,                       XK_Return, spawn,          {.v = termcmd } },
    { MODKEY,                       XK_m,      spawn,          {.v = vol_mute } },
    { MODKEY,                       XK_comma,  spawn,          {.v = vol_down } },
    { MODKEY,                       XK_period, spawn,          {.v = vol_up } },
    { MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
    { MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
    { MODKEY|ShiftMask,             XK_j,      movestack,      {.i = +1 } },
    { MODKEY|ShiftMask,             XK_k,      movestack,      {.i = -1 } },
    { MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
    { MODKEY,                       XK_o,      incnmaster,     {.i = -1 } },
    { MODKEY,                       XK_d,      killclient,     {0} },
    { MODKEY,                       XK_f,      togglefullscr,  {0} },
    { MODKEY,                       XK_bracketleft,  setmfact,       {.f = +0.05} },
    { MODKEY,                       XK_bracketright, setmfact,       {.f = -0.05} },
    { MODKEY,                       XK_space,        cyclelayout,    {.i = +1 } },
    { MODKEY|ControlMask,           XK_space,        cyclelayout,    {.i = -1 } },
    { MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
    { MODKEY,                       XK_h,      focusmon,       {.i = -1 } },
    { MODKEY,                       XK_l,      focusmon,       {.i = +1 } },
    { MODKEY|ShiftMask,             XK_h,      tagmon,         {.i = -1 } },
    { MODKEY|ShiftMask,             XK_l,      tagmon,         {.i = +1 } },
    TAGKEYS(                        XK_1,                      0)
    TAGKEYS(                        XK_2,                      1)
    TAGKEYS(                        XK_3,                      2)
    TAGKEYS(                        XK_4,                      3)
    TAGKEYS(                        XK_5,                      4)
    TAGKEYS(                        XK_6,                      5)
    TAGKEYS(                        XK_7,                      6)
    TAGKEYS(                        XK_8,                      7)
    TAGKEYS(                        XK_9,                      8)
    TAGKEYS(                        XK_0,                      9)
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
    /* click                event mask      button          function        argument */
    { ClkLtSymbol,          0,              Button1,        cyclelayout,    {.i = -1} },
    { ClkLtSymbol,          0,              Button3,        cyclelayout,    {.i = +1} },
    { ClkWinTitle,          0,              Button2,        zoom,           {0} },
    { ClkStatusText,        0,              Button2,        spawn,          {.v = vol_mute } },
    { ClkStatusText,        0,              Button4,        spawn,          {.v = vol_up } },
    { ClkStatusText,        0,              Button5,        spawn,          {.v = vol_down } },
    { ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
    { ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
    { ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
    { ClkTagBar,            0,              Button1,        view,           {0} },
    { ClkTagBar,            0,              Button3,        toggleview,     {0} },
    { ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
    { ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};

