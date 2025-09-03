import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotter/features/store/presentation/screens/store_news_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotter/features/stamp_and_tour/presentation/screens/user_nfc_scan_screen.dart';
import 'package:spotter/features/community_and_post/presentation/widgets/post_grid_item.dart';

class StoreDetailScreen extends StatefulWidget {
  final String storeId;
  final Map<String, dynamic> currentUser;

  const StoreDetailScreen({
    super.key,
    required this.storeId,
    required this.currentUser,
  });

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  String? _selectedRewardId;

  Future<void> _toggleFavorite() async {
    if (_currentUserId.isEmpty) return;
    final regularRef = _db.collection('stores').doc(widget.storeId).collection('regulars').doc(_currentUserId);
    final doc = await regularRef.get();
    if (doc.exists) {
      await regularRef.delete();
    } else {
      await regularRef.set({'favoritedAt': FieldValue.serverTimestamp()});
    }
  }

  Future<void> _startChallenge() async {
    if (_selectedRewardId == null || _currentUserId.isEmpty) return;
    if (!mounted) return;

    try {
      final rewardDoc = await _db.collection('stores').doc(widget.storeId).collection('rewards').doc(_selectedRewardId!).get();
      if (!rewardDoc.exists) {
        throw Exception('존재하지 않는 리워드입니다.');
      }

      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserNfcScanScreen(
          storeId: widget.storeId,
          rewardId: _selectedRewardId!,
          rewardData: rewardDoc.data()!,
        )));
      }
    } catch(e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _db.collection('stores').doc(widget.storeId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('가게 정보를 불러올 수 없습니다.')));
        }
        final storeData = snapshot.data!.data()!;

        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 250.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(storeData['storeName'] ?? '가게 이름', style: const TextStyle(shadows: [Shadow(blurRadius: 10.0, color: Colors.black)])),
                  background: Image.network(
                    storeData['imageUrl'] ?? 'https://picsum.photos/seed/${widget.storeId}/800/600',
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.3),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  _buildInfoSection(context, storeData),
                  _buildSection(
                    context: context,
                    title: '🎁 리워드 선택',
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: _db.collection('stores').doc(widget.storeId).collection('rewards').where('isActive', isEqualTo: true).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('현재 제공되는 리워드가 없습니다.'));
                          }
                          final rewards = snapshot.data!.docs;
                          return Column(
                            children: rewards.map((doc) {
                              final reward = doc.data() as Map<String, dynamic>;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: _buildRewardCard(
                                    context,
                                    icon: Icons.card_giftcard,
                                    title: reward['title'] ?? '',
                                    subtitle: '스탬프 ${reward['requiredStamps'] ?? '?'}개 필요',
                                    isSelected: _selectedRewardId == doc.id,
                                    onTap: () {
                                      setState(() {
                                        if (_selectedRewardId == doc.id) {
                                          _selectedRewardId = null;
                                        } else {
                                          _selectedRewardId = doc.id;
                                        }
                                      });
                                    }
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                  // [아우] 🔥🔥🔥 '가게 최신 소식' 부분을 StreamBuilder로 업그레이드했습니다. 🔥🔥🔥
                  _buildSection(
                    context: context,
                    title: '📢 가게 최신 소식',
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        // 사장님이 작성한 게시물 중 이 가게 ID를 가진 가장 최신 글 1개만 가져옵니다.
                          stream: _db.collection('owner_posts').where('storeId', isEqualTo: widget.storeId).orderBy('createdAt', descending: true).limit(1).snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()));
                            }
                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return const Text('최신 소식이 없습니다.');
                            }
                            final newsDoc = snapshot.data!.docs.first;
                            return InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => StoreNewsDetailScreen(
                                    storeId: widget.storeId,
                                    newsId: newsDoc.id,
                                    currentUser: widget.currentUser,
                                  )));
                                },
                                child: _buildNewsCard(context, newsDoc)
                            );
                          }
                      ),
                    ],
                  ),
                  _buildSection(
                    context: context,
                    title: '📸 방문객 인증샷',
                    children: [
                      _buildPhotoGrid(context)
                    ],
                  ),
                  const SizedBox(height: 100),
                ]),
              ),
            ],
          ),
          bottomSheet: _buildBottomSheet(context),
        );
      },
    );
  }

  Widget _buildInfoSection(BuildContext context, Map<String, dynamic> storeData) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(storeData['category'] ?? "카테고리", style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(storeData['story'] ?? "가게 설명이 없습니다.", style: const TextStyle(fontSize: 16, height: 1.5)),
          const SizedBox(height: 16),
          _InfoRow(icon: Icons.location_on_outlined, text: storeData['address'] ?? '주소 정보 없음'),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.access_time_outlined, text: storeData['hours'] ?? '영업 시간 정보 없음'),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
              stream: _db.collection('stores').doc(widget.storeId).collection('regulars').snapshots(),
              builder: (context, snapshot) {
                final count = snapshot.data?.size ?? 0;
                return _InfoRow(icon: Icons.people_alt_outlined, text: '단골: $count명');
              }
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required BuildContext context, required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRewardCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required bool isSelected, required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isSelected ? Colors.orange : Theme.of(context).dividerColor,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isSelected ? Colors.orange.withOpacity(0.1) : Colors.teal.withOpacity(0.1),
          foregroundColor: isSelected ? Colors.orange[800] : Colors.teal,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, DocumentSnapshot newsDoc) {
    final newsData = newsDoc.data() as Map<String, dynamic>;
    final imageUrl = newsData['imageUrl'] ?? 'https://picsum.photos/seed/${newsDoc.id}/200/200';
    final content = newsData['content'] ?? '내용 없음';
    final createdAt = (newsData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(content, maxLines: 3, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(
                  _formatTimeAgo(createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 12)
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inSeconds < 60) return '방금 전';
    if (difference.inMinutes < 60) return '${difference.inMinutes}분 전';
    if (difference.inHours < 24) return '${difference.inHours}시간 전';
    return '${difference.inDays}일 전';
  }

  Widget _buildPhotoGrid(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('storeId', isEqualTo: widget.storeId)
          .where('isCertified', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('아직 방문객 인증샷이 없습니다.');
        }
        final docs = snapshot.data!.docs;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
          ),
          itemCount: docs.length > 6 ? 6 : docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final itemWithId = {...data, 'id': docs[index].id};
            return PostGridItem(
              collectionPath: 'posts',
              post: itemWithId,
              currentUser: widget.currentUser,
            );
          },
        );
      },
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            StreamBuilder<DocumentSnapshot>(
                stream: _db.collection('stores').doc(widget.storeId).collection('regulars').doc(_currentUserId).snapshots(),
                builder: (context, snapshot) {
                  final isFavorited = snapshot.hasData && snapshot.data!.exists;
                  return OutlinedButton.icon(
                    onPressed: _toggleFavorite,
                    icon: FaIcon(isFavorited ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart, color: Colors.red[400]),
                    label: const Text('단골'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      foregroundColor: isFavorited ? Colors.red[400] : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  );
                }
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedRewardId != null ? _startChallenge : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.orange[400],
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: const Text('스탬프 도전하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}