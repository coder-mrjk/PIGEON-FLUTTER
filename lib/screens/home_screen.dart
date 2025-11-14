import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/providers/ai_provider.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/chat_provider.dart';
import '../core/providers/theme_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/asset_utils.dart';
import '../core/utils/validators.dart';
import '../widgets/animated_background.dart';
import '../widgets/custom_icon_button.dart' as custom_icons;
import 'ai_chat_screen.dart';
import 'ai_toolkit_chat_screen.dart';
import 'auth_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const ChatListScreen(),
    const AIAssistantScreen(),
    const SettingsScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedBackground(
        colors: [
          theme.colorScheme.primary,
          theme.colorScheme.secondary,
          theme.colorScheme.tertiary,
        ],
        duration: const Duration(seconds: 14),
        showParticles: true,
        brandLightAsset: 'assets/branding/backgrounds/light.png',
        brandDarkAsset: 'assets/branding/backgrounds/dark.png',
        brandOverlayOpacity: 0.08,
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(context, authState),

              // Main Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  children: _screens,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildAppBar(BuildContext context, AuthState authState) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final compact = w < 320;
          final tiny = w < 180;

          final titleText = Text(
            'Pigeon',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              fontSize: compact ? 20 : theme.textTheme.headlineMedium?.fontSize,
            ),
          );

          return Row(
            children: [
              // Logo and optional Title (responsive)
              Flexible(
                fit: FlexFit.loose,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: compact ? 32 : 40,
                        height: compact ? 32 : 40,
                        child: _PigeonLogoBox(),
                      ),
                    ),
                    if (!tiny) SizedBox(width: compact ? 8 : 12),
                    if (!tiny)
                      Flexible(
                        child: titleText,
                      ),
                  ],
                ),
              ),

              const Spacer(),

              // Theme Toggle (hide on ultra-narrow widths)
              if (!tiny)
                custom_icons.CustomIconButton(
                  icon: theme.brightness == Brightness.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  onPressed: () {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                  tooltip: 'Toggle Theme',
                  size: compact ? 20 : 24,
                  padding: EdgeInsets.all(compact ? 8 : 12),
                  borderRadius: compact ? 10 : 12,
                  showShadow: false,
                ),

              if (!tiny) SizedBox(width: compact ? 4 : 8),

              // Profile Menu (always shown)
              PopupMenuButton<String>(
                icon: CircleAvatar(
                  radius: compact ? 16 : 20,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    authState.user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'profile':
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                      break;
                    case 'settings':
                      setState(() {
                        _selectedIndex = 2;
                        _pageController.animateToPage(
                          2,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      });
                      break;
                    case 'logout':
                      _showLogoutDialog(context, ref);
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 8),
                        Text('Settings'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            activeIcon: Icon(Icons.psychology),
            label: 'AI Assistant',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton(
      onPressed: () async {
        if (_selectedIndex == 0) {
          _showNewChatDialog(context);
        } else if (_selectedIndex == 1) {
          final navigator = Navigator.of(context);
          final proceed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              contentPadding: const EdgeInsets.all(16),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: FutureBuilder<bool>(
                      future: AssetUtils.exists(
                          'assets/branding/ai/popup_logo.png'),
                      builder: (context, snapshot) {
                        final ok = snapshot.data ?? false;
                        if (ok) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/branding/ai/popup_logo.png',
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                        return Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.pigeonBlue,
                                AppTheme.pigeonAccent
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.psychology,
                            size: 48,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pigeon AI',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Supercharge your chats with AI. Let\'s go!',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Not now'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Continue'),
                ),
              ],
            ),
          );
          if (proceed == true) {
            navigator.push(
              MaterialPageRoute<void>(
                  builder: (context) => const AIChatScreen()),
            );
          }
        }
      },
      backgroundColor: theme.colorScheme.primary,
      child: Icon(
        _selectedIndex == 0 ? Icons.add : Icons.psychology,
        color: Colors.white,
      ),
    ).animate().scale(duration: 300.ms, curve: Curves.elasticOut);
  }

  void _showNewChatDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('New Direct Chat'),
              subtitle: const Text('Start a conversation with someone'),
              onTap: () {
                Navigator.of(context).pop();
                _showEmailDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('Create Group'),
              subtitle: const Text('Start a group conversation'),
              onTap: () {
                Navigator.of(context).pop();
                _showCreateGroupDialog(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showEmailDialog(BuildContext context) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Direct Chat'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter email address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: Validators.email,
            autofillHints: const [AutofillHints.email],
            keyboardType: TextInputType.emailAddress,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                await ref
                    .read(chatProvider.notifier)
                    .createDirectChatByEmail(controller.text.trim());
                if (context.mounted) {
                  Navigator.of(context).pop();
                  final err = ref.read(chatProvider).error;
                  if (err != null) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(err)));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Chat ready! Check your chats list.')),
                    );
                  }
                }
              }
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Group'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Group name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                ref.read(chatProvider.notifier).createGroupChat(
                  nameController.text.trim(),
                  [], // Empty members for now
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Group created!')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (context) => const AuthScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _PigeonLogoBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      child: FutureBuilder<String?>(
        future: AssetUtils.firstExisting(const [
          'assets/branding/logo/pigeon_logo.svg',
          'assets/branding/logo/pigeon_logo.png',
          'assets/branding/logo/pigeon_logo.jpg',
        ]),
        builder: (context, snapshot) {
          final path = snapshot.data;
          if (path == null) {
            return const Icon(Icons.flight, color: Colors.grey);
          }
          if (path.endsWith('.svg')) {
            return SvgPicture.asset(
              path,
              fit: BoxFit.cover,
              semanticsLabel: 'Pigeon Logo',
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary,
                BlendMode.srcIn,
              ),
              placeholderBuilder: (context) => const Icon(
                Icons.flight,
                color: Colors.grey,
              ),
            );
          }
          return Image.asset(
            path,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.flight,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }
}

// Placeholder screens
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final chatState = ref.watch(chatProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Chats',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: chatState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : chatState.chats.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No chats yet',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start a new conversation!',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: chatState.chats.length,
                        itemBuilder: (context, index) {
                          final chat = chatState.chats[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.primary,
                                child: Text(
                                  chat.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(chat.name),
                              subtitle: Text(
                                chat.lastMessage ?? 'No messages yet',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: chat.lastMessageTime != null
                                  ? Text(
                                      _formatTime(chat.lastMessageTime!),
                                      style: theme.textTheme.bodySmall,
                                    )
                                  : const Icon(Icons.chevron_right),
                              onTap: () {
                                ref
                                    .read(chatProvider.notifier)
                                    .loadMessages(chat.id);
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (context) =>
                                        ChatScreen(chat: chat),
                                  ),
                                );
                              },
                            ),
                          ).animate().slideX(
                                begin: 0.3,
                                end: 0,
                                duration: 300.ms,
                                delay: (index * 100).ms,
                              );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}

class AIAssistantScreen extends ConsumerWidget {
  const AIAssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final aiState = ref.watch(aiProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Assistant',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // AI Provider Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select AI Provider',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildProviderCard(
                          context,
                          'Auto',
                          'Smart routing',
                          Icons.auto_awesome,
                          AIProvider.auto,
                          aiState.selectedProvider,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildProviderCard(
                          context,
                          'OpenAI',
                          'GPT-4',
                          Icons.psychology,
                          AIProvider.openai,
                          aiState.selectedProvider,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildProviderCard(
                          context,
                          'Google',
                          'Gemini',
                          Icons.g_mobiledata,
                          AIProvider.google,
                          aiState.selectedProvider,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildProviderCard(
                          context,
                          'Perplexity',
                          'Sonar',
                          Icons.search,
                          AIProvider.perplexity,
                          aiState.selectedProvider,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Quick Actions
          Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildQuickActionCard(
                  context,
                  'Ask Question',
                  Icons.help_outline,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const AIChatScreen(),
                      ),
                    );
                  },
                ),
                _buildQuickActionCard(context, 'Code Help', Icons.code, () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const AIChatScreen(),
                    ),
                  );
                }),
                _buildQuickActionCard(context, 'Writing', Icons.edit, () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const AIChatScreen(),
                    ),
                  );
                }),
                _buildQuickActionCard(context, 'Research', Icons.search, () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const AIChatScreen(),
                    ),
                  );
                }),
                _buildQuickActionCard(
                    context, 'AI Toolkit (Gemini)', Icons.auto_awesome, () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const AIToolkitChatScreen(),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    AIProvider provider,
    AIProvider selectedProvider,
  ) {
    final theme = Theme.of(context);
    final isSelected = provider == selectedProvider;

    return Consumer(
      builder: (context, ref, _) {
        return GestureDetector(
          onTap: () {
            ref.read(aiProvider.notifier).setProvider(provider);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Catchy note banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.tips_and_updates, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pro tip: Make Pigeon yours — tweak themes and settings to match your vibe!',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildSettingsTile(
                  context,
                  'Theme',
                  'Change app theme',
                  Icons.palette,
                  () {
                    ref.read(themeProvider.notifier).toggleTheme();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Theme changed!')),
                    );
                  },
                ),
                _buildSettingsTile(
                  context,
                  'Notifications',
                  'Manage notifications',
                  Icons.notifications,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notification settings coming soon!'),
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  context,
                  'Privacy',
                  'Privacy settings',
                  Icons.privacy_tip,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Privacy settings coming soon!'),
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  context,
                  'About',
                  'App information',
                  Icons.info,
                  () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.pigeonBlue,
                                    AppTheme.pigeonAccent,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.flight,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pigeon',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Premium Chat Experience',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Version Badge
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppTheme.pigeonBlue,
                                          AppTheme.pigeonAccent,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'PV-1',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.orange.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.orange,
                                        width: 1,
                                      ),
                                    ),
                                    child: const Text(
                                      'BETA',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Mission Statement
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.pigeonBlue
                                          .withValues(alpha: 0.1),
                                      AppTheme.pigeonAccent
                                          .withValues(alpha: 0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.pigeonBlue
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.rocket_launch,
                                          color: AppTheme.pigeonBlue,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Our Mission',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'To contribute to India\'s digital economy by delivering a premium chat experience that seamlessly integrates real-time messaging with the power of multiple AI providers, making advanced communication accessible to everyone.',
                                      style: TextStyle(height: 1.6),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // What Makes Us Unique
                              const Text(
                                'What Makes Us Unique',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Pigeon stands out by combining the best of modern chat features with intelligent AI integration. Unlike traditional chat apps, we offer multi-provider AI support (OpenAI GPT-4, Google Gemini, and Perplexity), giving users the flexibility to choose the AI that best suits their needs—all within a beautifully crafted interface.',
                                style: TextStyle(height: 1.5),
                              ),
                              const SizedBox(height: 20),

                              // Features Section
                              const Text(
                                'Key Features',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildFeatureItem(
                                Icons.chat_bubble,
                                'Real-Time Messaging',
                                'Instant messaging powered by Firebase with live updates',
                              ),
                              _buildFeatureItem(
                                Icons.smart_toy,
                                'AI Assistant',
                                'Multi-provider AI support (OpenAI, Gemini, Perplexity)',
                              ),
                              _buildFeatureItem(
                                Icons.groups,
                                'Group Chats',
                                'Create and manage group conversations effortlessly',
                              ),
                              _buildFeatureItem(
                                Icons.palette,
                                'Beautiful UI',
                                'Glassmorphic design with dark/light theme support',
                              ),
                              _buildFeatureItem(
                                Icons.security,
                                'Secure',
                                'Firebase authentication with Google Sign-In support',
                              ),
                              const SizedBox(height: 20),

                              // Technology Section
                              const Text(
                                'Technology Stack',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '• Flutter & Dart\n'
                                '• Firebase (Auth, Firestore)\n'
                                '• Riverpod State Management\n'
                                '• OpenAI, Google Gemini, Perplexity APIs\n'
                                '• Web Platform (Chrome, Safari, Firefox)',
                                style: TextStyle(height: 1.8),
                              ),
                              const SizedBox(height: 20),

                              // Release Information
                              const Text(
                                'Release Schedule',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '🚀 Beta Release: November 5, 2025\n'
                                '✅ Stable Release: December 16, 2025',
                                style: TextStyle(height: 1.8),
                              ),
                              const SizedBox(height: 20),

                              // Developer & Team
                              const Text(
                                'Development Team',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                Icons.person,
                                'Developer',
                                'Jaikarthick T.S',
                              ),
                              _buildInfoRow(
                                Icons.business,
                                'Team',
                                'JSAI SYNERGIZ SOLUTIONS',
                              ),
                              _buildInfoRow(
                                Icons.location_on,
                                'Location',
                                'India',
                              ),
                              const SizedBox(height: 20),

                              // Contact & Links
                              const Text(
                                'Contact & Links',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildLinkRow(
                                Icons.email,
                                'Email',
                                'tonightgamermrjk@gmail.com',
                              ),
                              _buildLinkRow(
                                Icons.language,
                                'Website',
                                'Coming Soon',
                              ),
                              _buildLinkRow(
                                Icons.code,
                                'GitHub',
                                'github.com/coder-mrjk',
                              ),
                              const SizedBox(height: 20),

                              // Credits & Acknowledgments
                              const Text(
                                'Credits & Acknowledgments',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '🙏 Special Thanks To:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '• WARP AI - Development assistance and guidance',
                                      style:
                                          TextStyle(fontSize: 12, height: 1.6),
                                    ),
                                    Text(
                                      '• Sashvin - Financial support and backing',
                                      style:
                                          TextStyle(fontSize: 12, height: 1.6),
                                    ),
                                    Text(
                                      '• Flutter Team - Amazing framework',
                                      style:
                                          TextStyle(fontSize: 12, height: 1.6),
                                    ),
                                    Text(
                                      '• Firebase - Backend infrastructure',
                                      style:
                                          TextStyle(fontSize: 12, height: 1.6),
                                    ),
                                    Text(
                                      '• Open Source Community - Inspiration and resources',
                                      style:
                                          TextStyle(fontSize: 12, height: 1.6),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Footer
                              const Divider(),
                              const SizedBox(height: 12),
                              Center(
                                child: Column(
                                  children: [
                                    const Text(
                                      '© 2025 JSAI SYNERGIZ SOLUTIONS. All rights reserved.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Built with ❤️ in India using Flutter',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Version PV-1 (Pigeon Version 1)',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[500],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  context,
                  'Logout',
                  'Sign out of your account',
                  Icons.logout,
                  () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await ref.read(authProvider.notifier).signOut();
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute<void>(
                                    builder: (context) => const AuthScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.pigeonBlue, AppTheme.pigeonAccent],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.pigeonBlue),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.pigeonAccent),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[700],
                decoration: value != 'Coming Soon'
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
